import AppKit
import VidradoCore
import Combine
import ServiceManagement

@MainActor final class SettingsStore: ObservableObject {
    @Published var preferences: Preferences { didSet { save() } }
    @Published var message: String?
    @Published var loginEnabled = [.enabled, .requiresApproval].contains(SMAppService.mainApp.status)
    let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: "preferences"), let saved = try? JSONDecoder().decode(Preferences.self, from: data) {
            var safe = saved; safe.sanitize(); preferences = safe
        } else { preferences = Preferences() }
    }
    private func save() {
        if let data = try? JSONEncoder().encode(preferences) { defaults.set(data, forKey: "preferences") }
    }
    func setLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            loginEnabled = [.enabled, .requiresApproval].contains(SMAppService.mainApp.status)
            if SMAppService.mainApp.status == .requiresApproval {
                message = L10n.text("Allow Vidrado in System Settings → General → Login Items.")
            }
        } catch { message = L10n.format("Could not change launch at login: %@", error.localizedDescription) }
    }
    func addApp(sharp: Bool) {
        let picker = NSOpenPanel()
        picker.title = sharp ? L10n.text("Keep application clear") : L10n.text("Pause for this application")
        picker.directoryURL = URL(fileURLWithPath: "/Applications")
        picker.allowedContentTypes = [.applicationBundle]
        picker.allowsMultipleSelection = true
        guard picker.runModal() == .OK else { return }
        for url in picker.urls {
            guard let bundle = Bundle(url: url), let id = bundle.bundleIdentifier else { continue }
            let rule = AppRule(id: id, name: (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? url.deletingPathExtension().lastPathComponent)
            addRule(rule, sharp: sharp)
        }
    }
    func addRule(_ rule: AppRule, sharp: Bool) {
        if sharp {
            preferences.excludedApps.removeAll { $0.id == rule.id }
            if !preferences.sharpApps.contains(where: { $0.id == rule.id }) { preferences.sharpApps.append(rule) }
        } else {
            preferences.sharpApps.removeAll { $0.id == rule.id }
            if !preferences.excludedApps.contains(where: { $0.id == rule.id }) { preferences.excludedApps.append(rule) }
        }
    }
}

@MainActor final class FocusEngine: ObservableObject {
    @Published private(set) var status = L10n.text("Preparing focus…")
    @Published private(set) var activeApp = ""
    @Published private(set) var isApplying = false
    @Published private(set) var warning: String?
    let server = WindowServer()
    private let store: SettingsStore
    private var panels: [CGDirectDisplayID: OverlayPanel] = [:]
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    private var workspaceObservers: [NSObjectProtocol] = []
    private var sessionActive = true
    private var transitionUntil: TimeInterval = 0
    private var shake = ShakeDetector()
    private var lastRender = ""
    private var lastSharingCheck: TimeInterval = 0
    private var shared = false
    private var fullscreenIDs: Set<UInt32> = []
    var visiblePanelCount: Int { panels.values.filter(\.isVisible).count }

    init(store: SettingsStore) { self.store = store }
    func start() {
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didActivateApplicationNotification, NSWorkspace.activeSpaceDidChangeNotification,
                     NSWorkspace.didWakeNotification, NSWorkspace.sessionDidBecomeActiveNotification,
                     NSWorkspace.sessionDidResignActiveNotification, NSWorkspace.willSleepNotification] {
            workspaceObservers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] note in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    if note.name == NSWorkspace.sessionDidResignActiveNotification || note.name == NSWorkspace.willSleepNotification { self.sessionActive = false }
                    if note.name == NSWorkspace.sessionDidBecomeActiveNotification || note.name == NSWorkspace.didWakeNotification { self.sessionActive = true }
                    if note.name == NSWorkspace.activeSpaceDidChangeNotification {
                        self.lastSharingCheck = 0
                        self.transitionUntil = ProcessInfo.processInfo.systemUptime + 0.3
                        self.hide()
                    }
                    self.lastRender = ""
                    self.refresh()
                }
            })
        }
        observers.append(NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.panels.values.forEach { $0.close() }
                self?.panels.removeAll()
                self?.lastRender = ""
                self?.refresh()
            }
        })
        // Metadata only, 12.5 Hz. No screen images or accessibility polling.
        timer = Timer(timeInterval: 0.08, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        timer?.tolerance = 0.015
        RunLoop.main.add(timer!, forMode: .common)
        refresh()
    }
    func stop() {
        timer?.invalidate(); timer = nil
        observers.forEach(NotificationCenter.default.removeObserver)
        workspaceObservers.forEach(NSWorkspace.shared.notificationCenter.removeObserver)
        observers = []; workspaceObservers = []
        panels.values.forEach { $0.close() }; panels = [:]
    }
    private func hide() {
        panels.values.filter(\.isVisible).forEach { $0.orderOut(nil) }
        lastRender = ""
        if isApplying { isApplying = false }
    }
    func refresh() {
        let now = ProcessInfo.processInfo.systemUptime
        if store.preferences.shakeToToggle && shake.sample(NSEvent.mouseLocation, at: now) { store.preferences.enabled.toggle() }
        let p = store.preferences
        if now < transitionUntil { return }
        if !p.enabled || !sessionActive {
            hide(); setStatus(L10n.text(!p.enabled ? "Focus off" : "Session inactive")); return
        }
        if now - lastSharingCheck > 0.75 {
            shared = server.isScreenShared || NSScreen.screens.contains { screen in
                let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? UInt32 ?? 0
                return CGDisplayIsInMirrorSet(id) != 0
            }
            fullscreenIDs = server.fullscreenWindowIDs()
            lastSharingCheck = now
        }
        let windows = WindowServer.windows().filter { window in
            !panels.values.contains(where: { UInt32($0.windowNumber) == window.id })
        }
        let front = NSWorkspace.shared.frontmostApplication
        // Full-screen apps can expose a separate, narrow toolbar window before their document.
        let candidates = windows.filter { $0.pid == front?.processIdentifier && $0.layer == 0 && $0.bounds.width >= 80 && $0.bounds.height >= 80 }
        let active = candidates.first { fullscreenIDs.contains($0.id) } ?? candidates.first
        let screens = NSScreen.screens
        let primaryHeight = screens.first?.frame.height ?? 0
        let displayRects = screens.map { FocusGeometry.appKitFrame($0.frame, primaryHeight: primaryHeight) }
        if let reason = FocusPolicy.pause(preferences: p, active: active, displays: displayRects, sharing: shared, sessionActive: sessionActive, fullscreenSpace: active.map { fullscreenIDs.contains($0.id) } ?? false) {
            hide(); setStatus(L10n.text([PauseReason.off: "Focus off", .desktop: "No focused window", .excluded: "Excluded application", .fullscreen: "Paused in full screen", .sharing: "Paused during screen sharing", .session: "Session inactive"][reason]!)); return
        }
        guard let active else { hide(); return }
        let name = front?.localizedName ?? L10n.text("Application")
        if activeApp != name { activeApp = name }
        let focusedScreenIndex = displayRects.indices.max { a, b in
            let ra = displayRects[a].intersection(active.bounds), rb = displayRects[b].intersection(active.bounds)
            return (ra.isNull ? 0 : ra.width * ra.height) < (rb.isNull ? 0 : rb.width * rb.height)
        } ?? 0
        let visibleRect = screens.indices.contains(focusedScreenIndex)
            ? FocusGeometry.appKitFrame(screens[focusedScreenIndex].visibleFrame, primaryHeight: primaryHeight) : active.bounds
        let holes = FocusGeometry.sharpRegions(windows: windows, active: active, sharpBundles: Set(p.sharpApps.map(\.id)), keepTiled: p.keepTiled, visibleDisplay: visibleRect)
        let signature = "\(active.id)|\(windows.map(\.id))|\(holes)|\(p.blurRadius)|\(p.dimOpacity)|\(p.allDisplays)|\(focusedScreenIndex)|\(displayRects)"
        guard signature != lastRender else { return }
        lastRender = signature
        var failed = false
        for (index, screen) in screens.enumerated() {
            let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? UInt32 ?? UInt32(index)
            if !p.allDisplays && index != focusedScreenIndex { panels[id]?.orderOut(nil); continue }
            let panel = panels[id] ?? OverlayPanel(frame: screen.frame)
            panels[id] = panel
            if panel.frame != screen.frame { panel.setFrame(screen.frame, display: true) }
            let region = FocusGeometry.shapeRegion(holes: holes, display: displayRects[index])
            if region.isEmpty { panel.orderOut(nil); continue }
            panel.backgroundColor = NSColor.black.withAlphaComponent(max(0.001, p.dimOpacity))
            panel.order(.below, relativeTo: Int(active.id))
            let blurOK = server.setBlur(window: panel, radius: p.blurRadius)
            let shapeOK = server.setShape(window: panel, rectangles: region)
            if !shapeOK && !holes.isEmpty { panel.orderOut(nil) }
            failed = failed || !blurOK || !shapeOK
        }
        let nextWarning = failed ? L10n.text("macOS could not apply the full effect. Pause focus or try Dim.") : nil
        if warning != nextWarning { warning = nextWarning }
        if !isApplying { isApplying = true }
        setStatus(L10n.format("In focus · %@", name))
    }
    private func setStatus(_ value: String) { if status != value { status = value } }
}
