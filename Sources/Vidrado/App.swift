import AppKit
import SwiftUI
import Combine
import CoreText
import VidradoCore

@main struct VidradoApp {
    @MainActor static func main() {
        if let url = L10n.fontURL { CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) }
        let app = NSApplication.shared
        if CommandLine.arguments.contains("--self-test") { exit(NativeChecks.run() ? 0 : 1) }
        if CommandLine.arguments.contains("--inspect") {
            let server = WindowServer()
            let report: [String: Any] = [
                "blurAvailable": server.supportsBlur, "shapeAvailable": server.supportsShape,
                "screenShared": server.isScreenShared,
                "fullscreenWindowIDs": Array(server.fullscreenWindowIDs()),
                "frontPID": NSWorkspace.shared.frontmostApplication?.processIdentifier ?? 0,
                "displays": NSScreen.screens.map { NSStringFromRect($0.frame) },
                "windows": WindowServer.windows().map { ["id": $0.id, "pid": $0.pid, "bundleID": $0.bundleID, "bounds": NSStringFromRect($0.bounds), "layer": $0.layer] as [String: Any] }
            ]
            if let data = try? JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]) { print(String(decoding: data, as: UTF8.self)) }
            return
        }
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) { app.run() }
    }
}

@MainActor private final class DesignWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = SettingsStore()
    lazy var engine = FocusEngine(store: store)
    let hotKey = HotKey()
    private var statusItem: NSStatusItem!
    private var popover = NSPopover()
    private var settingsWindow: NSWindow?
    private var subscription: AnyCancellable?
    private var shortcut: String = ""

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent multiple instances from stacking overlays.
        if let bundleID = Bundle.main.bundleIdentifier,
           NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).contains(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
            NSApp.terminate(nil); return
        }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let url = L10n.focusMarkURL, let image = NSImage(contentsOf: url) {
            image.size = NSSize(width: 22, height: 22)
            image.isTemplate = true
            statusItem.button?.image = image
        } else {
            statusItem.button?.image = NSImage(systemSymbolName: "rectangle.on.rectangle", accessibilityDescription: "Vidrado")
        }
        statusItem.button?.toolTip = L10n.text("Vidrado — focus for your Mac")
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuView(store: store, engine: engine) { [weak self] in self?.showSettings() } quit: { [weak self] in self?.quit() })
        hotKey.action = { [weak self] in self?.store.preferences.enabled.toggle() }
        subscription = store.$preferences.receive(on: RunLoop.main).sink { [weak self] preferences in
            guard let self else { return }
            let value = "\(preferences.shortcutKey)-\(preferences.shortcutModifiers)"
            if value != self.shortcut {
                self.shortcut = value
                if !self.hotKey.register(key: preferences.shortcutKey, modifiers: preferences.shortcutModifiers) {
                    self.store.message = L10n.text("This shortcut is in use. Choose another in Preferences.")
                }
            }
            self.statusItem.button?.appearsDisabled = !preferences.enabled
            self.engine.refresh()
        }
        installMenu()
        engine.start()
        if !store.defaults.bool(forKey: "hasLaunched") || CommandLine.arguments.contains("--settings") {
            store.defaults.set(true, forKey: "hasLaunched")
            showSettings()
        }
    }
    private func installMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        let menu = NSMenu()
        menu.addItem(withTitle: L10n.text("About Vidrado"), action: #selector(about), keyEquivalent: "")
        menu.addItem(withTitle: L10n.text("Quick controls"), action: #selector(togglePopover), keyEquivalent: "")
        menu.addItem(withTitle: L10n.text("Toggle focus"), action: #selector(toggleFocus), keyEquivalent: "")
        menu.addItem(withTitle: L10n.text("Preferences"), action: #selector(showSettings), keyEquivalent: ",")
        menu.addItem(withTitle: L10n.text("Close window"), action: #selector(closeSettings), keyEquivalent: "w")
        menu.addItem(.separator())
        menu.addItem(withTitle: L10n.text("Quit Vidrado"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = menu; main.addItem(appItem)
        let edit = NSMenuItem(); let editMenu = NSMenu(title: L10n.text("Edit"))
        for (title, action, key) in [(L10n.text("Undo"), "undo:", "z"), (L10n.text("Cut"), "cut:", "x"), (L10n.text("Copy"), "copy:", "c"), (L10n.text("Paste"), "paste:", "v"), (L10n.text("Select all"), "selectAll:", "a")] {
            editMenu.addItem(withTitle: title, action: Selector(action), keyEquivalent: key)
        }
        edit.submenu = editMenu; main.addItem(edit)
        NSApp.mainMenu = main
    }
    @objc private func togglePopover() {
        if NSApp.currentEvent?.type == .rightMouseUp || NSApp.currentEvent?.modifierFlags.contains(.option) == true {
            store.preferences.enabled.toggle(); return
        }
        if popover.isShown { popover.performClose(nil) }
        else if let button = statusItem.button { popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY) }
    }
    @objc private func toggleFocus() { store.preferences.enabled.toggle() }
    @objc func quit() { popover.performClose(nil); NSApp.terminate(nil) }
    @objc func showSettings() {
        popover.performClose(nil)
        if settingsWindow == nil {
            let window = DesignWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 800), styleMask: [.borderless, .closable, .miniaturizable], backing: .buffered, defer: false)
            window.title = "Vidrado"
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = false
            window.hasShadow = true
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: SettingsView(store: store, engine: engine) { [weak self] in self?.quit() })
            window.center()
            window.setFrameAutosaveName("VidradoDesignSettings")
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    @objc private func closeSettings() { settingsWindow?.close() }
    @objc private func about() {
        NSApp.orderFrontStandardAboutPanel(options: [.applicationName: "Vidrado", .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.1", .credits: NSAttributedString(string: L10n.text("Native focus for macOS. No subscription, tracking or screen capture."))])
        NSApp.activate(ignoringOtherApps: true)
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showSettings(); return true }
    func applicationWillTerminate(_ notification: Notification) { engine.stop(); hotKey.unregister() }
}
