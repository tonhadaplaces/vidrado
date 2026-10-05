import AppKit
import VidradoCore
import Carbon

enum NativeChecks {
    @MainActor static func run() -> Bool {
        NSApp.setActivationPolicy(.accessory)
        NSApp.finishLaunching()
        var failures: [String] = []
        func check(_ condition: Bool, _ label: String) {
            print("\(condition ? "PASS" : "FAIL") \(label)")
            if !condition { failures.append(label) }
        }
        let server = WindowServer()
        check(server.supportsBlur, "WindowServer blur symbol")
        check(server.supportsShape, "WindowServer region symbols")
        check(server.supportsCaptureDetection, "Screen sharing detection symbol")
        check(server.supportsSpaceDetection, "Full-screen Space detection symbol")
        let panel = OverlayPanel(frame: CGRect(x: -2000, y: -2000, width: 320, height: 240))
        panel.orderFrontRegardless()
        check(server.setBlur(window: panel, radius: 30), "Apply real blur to native window")
        check(server.setBlur(window: panel, radius: 0), "Remove real blur")
        let pieces = FocusGeometry.subtract([CGRect(x: 60, y: 50, width: 120, height: 90)], from: CGRect(x: 0, y: 0, width: 320, height: 240))
        check(server.setShape(window: panel, rectangles: pieces), "Apply disjoint clip region for pinned apps")
        check((0..<500).allSatisfy { _ in server.setShape(window: panel, rectangles: pieces) }, "500 region updates safely release C handles")
        check(panel.ignoresMouseEvents && !panel.canBecomeKey && !panel.canBecomeMain, "Overlay cannot intercept clicks or focus")
        panel.orderOut(nil)
        check(!panel.isVisible, "Disable removes overlay")
        panel.close()
        let hotKey = HotKey()
        check(hotKey.register(key: 11, modifiers: 2304), "Register global Option Command B")
        var triggered = false
        hotKey.action = { triggered = true }
        var event: EventRef?
        CreateEvent(nil, OSType(kEventClassKeyboard), UInt32(kEventHotKeyPressed), GetCurrentEventTime(), 0, &event)
        if let event {
            var id = EventHotKeyID(signature: 0x56494452, id: 1)
            SetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), MemoryLayout<EventHotKeyID>.size, &id)
            SendEventToEventTarget(event, GetApplicationEventTarget())
            ReleaseEvent(event)
        }
        check(triggered, "Native hotkey event dispatch invokes action")
        hotKey.unregister()
        check(hotKey.register(key: 11, modifiers: 2304), "Unregister and re-register shortcut")
        hotKey.unregister()
        let suiteName = "app.vidrado.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = SettingsStore(defaults: defaults)
        store.preferences.dim = 63
        store.preferences.mode = .dim
        check(SettingsStore(defaults: defaults).preferences.dim == 63, "Preferences persist across store instances")
        store.addRule(.init(id: "com.example.Test", name: "Test"), sharp: true)
        store.addRule(.init(id: "com.example.Test", name: "Test"), sharp: true)
        check(store.preferences.sharpApps.count == 1, "App rules deduplicate")
        store.addRule(.init(id: "com.example.Test", name: "Test"), sharp: false)
        check(store.preferences.sharpApps.isEmpty && store.preferences.excludedApps.count == 1, "Conflicting app rules move to chosen list")
        defaults.set(Data("invalid".utf8), forKey: "preferences")
        check(SettingsStore(defaults: defaults).preferences == Preferences(), "Corrupt preferences recover with defaults")
        check(!WindowServer.windows().isEmpty, "Read visible window metadata")
        let currentPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
        guard WindowServer.windows().contains(where: { $0.pid == currentPID && $0.layer == 0 && $0.bounds.height >= 80 }) else {
            print("PRECONDITION: unlock macOS and keep a normal application window active (for example Terminal) to test cross-process compositor ordering. The login screen/desktop has no focus window. No live overlays were created.")
            return false
        }
        let liveStore = SettingsStore(defaults: defaults)
        // Use dimming so the compositor lists the live ordering fixture.
        liveStore.preferences.mode = .both
        liveStore.preferences.pauseScreenSharing = false
        liveStore.preferences.pauseFullscreen = false
        let engine = FocusEngine(store: liveStore)
        engine.refresh()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        check(engine.isApplying && engine.coveredDisplayCount == NSScreen.screens.count && engine.visiblePanelCount > 0, "Live engine covers every connected display")
        let ordered = WindowServer.windows().filter { $0.layer == 0 }
        let frontPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
        if let activeIndex = ordered.firstIndex(where: { $0.pid == frontPID }),
           let effectIndex = ordered.firstIndex(where: { $0.pid == ProcessInfo.processInfo.processIdentifier }) {
            check(activeIndex < effectIndex, "Overlay is behind another application's active window")
        } else {
            print("DETAIL: initial active PID \(currentPID ?? 0), current active PID \(frontPID ?? 0), test PID \(ProcessInfo.processInfo.processIdentifier), compositor PIDs \(ordered.map { $0.pid })")
            check(false, "Find active window and overlay in compositor order")
        }
        liveStore.preferences.enabled = false
        engine.refresh()
        check(engine.visiblePanelCount == 0, "Live disable removes all display overlays")
        liveStore.preferences.enabled = true
        let bundle = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
        liveStore.addRule(.init(id: bundle, name: "Test"), sharp: false)
        engine.refresh()
        check(engine.visiblePanelCount == 0 && engine.status == L10n.text("Excluded application"), "Live app exclusion pauses effect")
        liveStore.preferences.excludedApps = []
        engine.refresh()
        check(engine.visiblePanelCount > 0, "Live effect resumes after exclusion removed")
        engine.stop()
        check(engine.visiblePanelCount == 0, "Engine shutdown removes overlays")
        print("Native checks: \(failures.isEmpty ? "all passed" : "\(failures.count) failed")")
        return failures.isEmpty
    }
}
