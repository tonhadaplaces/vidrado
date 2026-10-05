import SwiftUI
import VidradoCore

private func tr(_ key: String) -> String { L10n.text(key) }
private func tone(_ light: UInt32, _ dark: UInt32) -> Color {
    Color(nsColor: NSColor(name: nil) { appearance in
        let value = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
        return NSColor(srgbRed: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255, alpha: 1)
    })
}
private let ink = tone(0x171717, 0xEEEEEE)
private let secondary = tone(0x888888, 0xAAAAAA)
private let rowLine = tone(0xEEEEEE, 0x3D3D3D)
private let paper = tone(0xFFFFFF, 0x242424)
private let surface = tone(0xF4F4F4, 0x303030)
private func inter(_ size: CGFloat, _ weight: String = "Regular") -> Font {
    .custom(weight == "Regular" ? "Inter-Regular" : "Inter-Regular_\(weight)", fixedSize: size)
}

private struct CopyText: View {
    let text: String
    var size: CGFloat = 12
    var weight = "Regular"
    var color = ink
    var tracking: CGFloat = 0
    var body: some View {
        Text(text).font(inter(size, weight)).tracking(tracking).foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct PencilIcon: View {
    let name: String
    var size: CGFloat = 17
    var color = ink
    var body: some View {
        if let url = L10n.imageURL(name), let image = NSImage(contentsOf: url) {
            Image(nsImage: image).renderingMode(.template).resizable().frame(width: size, height: size).foregroundStyle(color)
        }
    }
}

private struct WindowDragArea: NSViewRepresentable {
    final class DragView: NSView {
        override func mouseDown(with event: NSEvent) { window?.performDrag(with: event) }
    }
    func makeNSView(context: Context) -> DragView { DragView() }
    func updateNSView(_ view: DragView, context: Context) {}
}

struct FocusMark: View {
    var body: some View { PencilIcon(name: "i8tq5x", size: 30) }
}

private struct PencilSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.label.frame(maxWidth: .infinity, alignment: .leading)
            Button { configuration.isOn.toggle() } label: {
                Capsule().fill(configuration.isOn ? tone(0x222222, 0xDDDDDD) : tone(0xDDDDDD, 0x555555))
                    .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                        Circle().fill(tone(0xFFFFFF, 0x242424)).frame(width: 13, height: 13).padding(3)
                    }.frame(width: 32, height: 19)
            }.buttonStyle(.plain)
        }.accessibilityElement(children: .combine)
            .accessibilityValue(configuration.isOn ? tr("On") : tr("Off"))
            .accessibilityAction { configuration.isOn.toggle() }
    }
}

private struct PencilSlider: View {
    @Binding var value: Double
    let title: String
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let fraction = min(1, max(0, value / 100))
            let center = min(width - 9, max(9, width * (L10n.isRTL ? 1 - fraction : fraction)))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2).fill(tone(0xE8E8E8, 0x4B4B4B)).frame(height: 4)
                RoundedRectangle(cornerRadius: 2).fill(tone(0x222222, 0xDDDDDD)).frame(width: width * fraction, height: 4)
                Circle().fill(paper).overlay(Circle().strokeBorder(tone(0x222222, 0xDDDDDD), lineWidth: 2))
                    .frame(width: 18, height: 18).position(x: center, y: 9)
            }.frame(height: 18).contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { event in
                    let position = event.location.x / max(1, width)
                    value = min(100, max(0, (L10n.isRTL ? 1 - position : position) * 100))
                })
        }.frame(height: 18).focusable().focusEffectDisabled()
            .onMoveCommand { direction in
                if direction == .left { value = max(0, value - 5) }
                if direction == .right { value = min(100, value + 5) }
            }
            .accessibilityElement().accessibilityLabel(title)
            .accessibilityValue(Text(value / 100, format: .percent.precision(.fractionLength(0))))
            .accessibilityAdjustableAction { direction in
                value = min(100, max(0, value + (direction == .increment ? 5 : -5)))
            }
    }
}

struct FocusPreview: View {
    let preferences: Preferences
    var body: some View {
        VStack(spacing: 8) {
            CopyText(text: tr("DISTRACTIONS, OUT OF SIGHT"), size: 9, weight: "SemiBold", color: tone(0x737373, 0xAAAAAA), tracking: 1.4)
                .frame(minHeight: 11)
            CopyText(text: tr(preferences.enabled ? "You’re in the clear." : "Take a breather."), size: 28, weight: "Medium", tracking: -1)
                .frame(minHeight: 34)
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    backgroundWindow.offset(x: 16, y: 28)
                    backgroundWindow.offset(x: geometry.size.width - 174, y: 28)
                    VStack(alignment: .leading, spacing: 12) {
                        PencilIcon(name: "file-text", size: 15)
                        CopyText(text: tr("Just this. Nothing else."), size: 12, weight: "Medium", color: tone(0x252525, 0xE2E2E2))
                            .frame(minHeight: 15)
                        Rectangle().fill(tone(0xE2E2E2, 0x505050)).frame(width: 135, height: 3)
                        Spacer(minLength: 0)
                    }.padding(15).frame(width: 196, height: 108, alignment: .topLeading)
                        .background(paper, in: RoundedRectangle(cornerRadius: 7))
                        .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(tone(0xDCDCDC, 0x545454), lineWidth: 1))
                        .shadow(color: .black.opacity(0.063), radius: 9, y: 6)
                        .offset(x: (geometry.size.width - 196) / 2, y: 12)
                }
            }.frame(height: 126)
            HStack(spacing: 7) {
                Circle().fill(ink).frame(width: 5, height: 5)
                CopyText(text: tr("Following your active window"), size: 11, color: tone(0x737373, 0xAAAAAA))
            }.frame(minHeight: 13)
            Spacer(minLength: 0)
        }.padding(24).frame(maxWidth: .infinity).frame(height: 278, alignment: .top)
            .background(surface, in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .ignore).accessibilityLabel(tr("Preview: the active window stays clear"))
    }
    private var backgroundWindow: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach([95.0, 66.0, 82.0], id: \.self) { width in
                RoundedRectangle(cornerRadius: 2).fill(tone(0xA8A8A8, 0x707070)).frame(width: width, height: 4)
            }
            Spacer(minLength: 0)
        }.padding(14).frame(width: 142, height: 80, alignment: .topLeading)
            .background(tone(0xCFCFCF, 0x525252), in: RoundedRectangle(cornerRadius: 5))
            .blur(radius: preferences.enabled ? 7 : 0)
    }
}

struct IntensityControl: View {
    @ObservedObject var store: SettingsStore
    private var intensity: Binding<Double> {
        Binding(get: { store.preferences.mode == .dim ? store.preferences.dim : store.preferences.blur }, set: { value in
            if store.preferences.mode != .dim { store.preferences.blur = value }
            if store.preferences.mode != .blur { store.preferences.dim = value }
        })
    }
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                CopyText(text: tr("Hide distractions"), size: 14, weight: "Medium", color: tone(0x252525, 0xE2E2E2))
                Spacer()
                Text(intensity.wrappedValue / 100, format: .percent.precision(.fractionLength(0)))
                    .font(inter(13)).foregroundStyle(tone(0x737373, 0xAAAAAA))
            }.frame(minHeight: 17)
            PencilSlider(value: intensity, title: tr("Hide distractions"))
            HStack {
                CopyText(text: tr("A little quieter"), size: 10, color: tone(0x8A8A8A, 0xA5A5A5))
                Spacer()
                CopyText(text: tr("Nothing but focus"), size: 10, color: tone(0x8A8A8A, 0xA5A5A5))
            }.frame(minHeight: 12)
        }
    }
}

struct FocusHome: View {
    @ObservedObject var store: SettingsStore
    @ObservedObject var engine: FocusEngine
    let openApps: () -> Void
    let openSettings: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 10) {
                FocusMark()
                CopyText(text: "vidrado", size: 20, weight: "SemiBold", tracking: -0.7)
                WindowDragArea().frame(maxWidth: .infinity).frame(height: 33)
                Button(action: openSettings) { PencilIcon(name: "sliders-horizontal").padding(8) }
                    .buttonStyle(.plain)
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(tone(0xE5E5E5, 0x484848), lineWidth: 1))
                    .help(tr("Preferences")).accessibilityLabel(tr("Preferences"))
            }.frame(height: 33)
            FocusPreview(preferences: store.preferences)
            Button { store.preferences.enabled.toggle() } label: {
                HStack(spacing: 10) {
                    if store.preferences.enabled { PencilIcon(name: "pause", color: paper) }
                    else { Image(systemName: "play").font(inter(17)).foregroundStyle(paper) }
                    CopyText(text: tr(store.preferences.enabled ? "Pause focus" : "Resume focus"), size: 14, weight: "Medium", color: paper)
                }.frame(maxWidth: .infinity).frame(height: 52)
                    .background(tone(0x181818, 0xE8E8E8), in: RoundedRectangle(cornerRadius: 9))
            }.buttonStyle(.plain)
            IntensityControl(store: store)
            HStack(spacing: 8) {
                level("Light", icon: "sun", value: 30)
                level("Balanced", icon: "circle-dot", value: 65)
                level("Deep", icon: "eclipse", value: 90)
            }
            Button(action: openApps) {
                HStack(spacing: 10) {
                    PencilIcon(name: "panels-top-left", size: 18)
                    CopyText(text: tr("Keep some apps clear"))
                    Spacer(minLength: 8)
                    CopyText(text: L10n.format("%@ apps", String(store.preferences.sharpApps.count)), size: 11, color: secondary)
                    PencilIcon(name: "chevron-right", size: 15, color: secondary)
                }.frame(maxWidth: .infinity).frame(minHeight: 18).padding(.vertical, 16)
            }.buttonStyle(.plain).overlay(alignment: .top) { Rectangle().fill(tone(0xEAEAEA, 0x404040)).frame(height: 1) }
            HStack {
                CopyText(text: "\(Shortcut.label(key: store.preferences.shortcutKey, modifiers: store.preferences.shortcutModifiers, spacing: " "))  \(tr("to toggle anytime"))", size: 10, color: secondary)
                Spacer(minLength: 8)
                CopyText(text: tr("On-device. Always."), size: 10, color: secondary)
            }.frame(minHeight: 12)
        }
    }
    private func level(_ title: String, icon: String, value: Double) -> some View {
        let current = store.preferences.mode == .dim ? store.preferences.dim : store.preferences.blur
        let selected = current == value
        return Button {
            if store.preferences.mode != .dim { store.preferences.blur = value }
            if store.preferences.mode != .blur { store.preferences.dim = value }
        } label: {
            HStack(spacing: 7) {
                PencilIcon(name: icon, size: 15)
                CopyText(text: tr(title), size: 11, weight: selected ? "SemiBold" : "Regular", color: tone(0x363636, 0xDDDDDD))
            }.frame(maxWidth: .infinity).frame(height: 42)
                .background(selected ? tone(0xEEEEEE, 0x373737) : paper, in: RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(selected ? tone(0x222222, 0xCCCCCC) : tone(0xE5E5E5, 0x484848), lineWidth: 1))
        }.buttonStyle(.plain)
    }
}

private struct BackNavigation: View {
    let back: () -> Void
    var body: some View {
        HStack {
            Button(action: back) {
                HStack(spacing: 8) { PencilIcon(name: "arrow-left", size: 18); CopyText(text: tr("Focus")) }
            }.buttonStyle(.plain)
            WindowDragArea().frame(maxWidth: .infinity).frame(height: 18)
            CopyText(text: tr("Changes saved"), size: 10, color: secondary)
        }.frame(height: 18)
    }
}

private struct DesignScreen<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) { content }
                .padding(24).frame(maxWidth: .infinity, minHeight: 800, alignment: .topLeading)
        }.scrollIndicators(.hidden).frame(width: 480, height: 800)
            .background(paper).clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(tone(0xE0E0E0, 0x484848), lineWidth: 1))
            .tint(ink).foregroundStyle(ink)
            .environment(\.layoutDirection, L10n.isRTL ? .rightToLeft : .leftToRight)
            .environment(\.locale, Locale(identifier: L10n.language))
    }
}

struct MenuView: View {
    @ObservedObject var store: SettingsStore
    @ObservedObject var engine: FocusEngine
    let openSettings: () -> Void
    @State private var apps = false
    var body: some View {
        DesignScreen {
            if apps {
                BackNavigation { apps = false }
                AppRulesView(store: store)
            } else {
                FocusHome(store: store, engine: engine, openApps: { apps = true }, openSettings: openSettings)
            }
            if let warning = engine.warning { CopyText(text: warning, size: 11, color: .orange) }
        }
    }
}

private final class RuleMenuAction: NSObject {
    let run: () -> Void
    init(_ run: @escaping () -> Void) { self.run = run }
    @objc func invoke() { run() }
}

struct AppRulesView: View {
    @ObservedObject var store: SettingsStore
    @State private var search = ""
    @State private var installed: [AppRule] = []
    private var apps: [AppRule] {
        var rules = installed
        for app in store.preferences.sharpApps + store.preferences.excludedApps where !rules.contains(where: { $0.id == app.id }) { rules.append(app) }
        return rules.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                CopyText(text: tr("Your apps. Your rules."), size: 27, weight: "Medium", tracking: -1).frame(minHeight: 33)
                CopyText(text: tr("Decide what fades into the background. Your active window always stays clear.").replacingOccurrences(of: ". Your", with: ".\nYour"), size: 12, color: tone(0x777777, 0xABABAB))
                    .lineSpacing(4.2).frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
            }
            HStack(spacing: 10) {
                PencilIcon(name: "search", size: 16, color: secondary)
                TextField("", text: $search, prompt: Text(tr("Find an app…")).foregroundColor(tone(0x929292, 0xA2A2A2)))
                    .textFieldStyle(.plain).font(inter(12)).accessibilityLabel(tr("Find an app…"))
            }.padding(.horizontal, 13).frame(height: 42).background(tone(0xF5F5F5, 0x303030), in: RoundedRectangle(cornerRadius: 7))
            VStack(spacing: 0) {
                HStack {
                    CopyText(text: tr("APPLICATION"), size: 9, color: secondary, tracking: 1)
                    Spacer()
                    CopyText(text: tr("BEHAVIOR"), size: 9, color: secondary, tracking: 1)
                }.frame(minHeight: 11).padding(.bottom, 10)
                ScrollView {
                    LazyVStack(spacing: 0) { ForEach(apps) { app in appRow(app) } }
                }.scrollIndicators(.hidden).frame(height: 402)
            }
            HStack(alignment: .top, spacing: 10) {
                PencilIcon(name: "info", size: 15, color: secondary)
                CopyText(text: tr("“Pause focus” turns off the effect whenever that app is active. No need to toggle it yourself."), size: 11, color: secondary)
                    .lineSpacing(4.4).frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
            }
        }.onAppear { loadApps() }
    }
    private func appRow(_ app: AppRule) -> some View {
        let value = rule(app.id)
        let titles = ["Auto blur", "Keep clear", "Pause focus"]
        return HStack(spacing: 12) {
            Group {
                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.id) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: url.path)).resizable().scaledToFit()
                        .frame(width: 17, height: 17).saturation(0)
                } else {
                    PencilIcon(name: "panels-top-left", color: tone(0x555555, 0xBBBBBB))
                }
            }.frame(width: 34, height: 34).background(surface, in: RoundedRectangle(cornerRadius: 8))
            CopyText(text: app.name, size: 12, weight: "Medium", color: tone(0x303030, 0xDDDDDD))
            Spacer(minLength: 8)
            Button { showRuleMenu(app) } label: {
                HStack(spacing: 7) {
                    CopyText(text: tr(titles[value]), size: 10, color: value == 0 ? tone(0x999999, 0xA0A0A0) : tone(0x333333, 0xDDDDDD))
                    PencilIcon(name: "chevron-down", size: 12, color: secondary)
                }.padding(.horizontal, 9).padding(.vertical, 7)
                    .background(value == 1 ? tone(0xECECEC, 0x404040) : .clear, in: RoundedRectangle(cornerRadius: 5))
            }.buttonStyle(.plain).fixedSize()
                .accessibilityLabel("\(app.name): \(tr(titles[value]))")
        }.frame(height: 67).overlay(alignment: .top) { Rectangle().fill(rowLine).frame(height: 1) }
    }
    private func showRuleMenu(_ app: AppRule) {
        guard let event = NSApp.currentEvent, let window = event.window, let content = window.contentView else { return }
        let menu = NSMenu()
        for (option, title) in ["Auto blur", "Keep clear", "Pause focus"].enumerated() {
            let action = RuleMenuAction {
                store.preferences.sharpApps.removeAll { $0.id == app.id }
                store.preferences.excludedApps.removeAll { $0.id == app.id }
                if option != 0 { store.addRule(app, sharp: option == 1) }
            }
            let item = NSMenuItem(title: tr(title), action: #selector(RuleMenuAction.invoke), keyEquivalent: "")
            item.target = action
            item.representedObject = action
            item.state = option == rule(app.id) ? .on : .off
            menu.addItem(item)
        }
        menu.popUp(positioning: nil, at: content.convert(event.locationInWindow, from: nil), in: content)
    }
    private func rule(_ id: String) -> Int {
        store.preferences.sharpApps.contains { $0.id == id } ? 1 : store.preferences.excludedApps.contains { $0.id == id } ? 2 : 0
    }
    private func loadApps() {
        var found: [String: AppRule] = [:]
        for directory in ["/Applications", "/System/Applications", "/System/Applications/Utilities"] {
            guard let urls = try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: directory), includingPropertiesForKeys: nil) else { continue }
            for url in urls where url.pathExtension == "app" {
                guard let bundle = Bundle(url: url), let id = bundle.bundleIdentifier, id != Bundle.main.bundleIdentifier else { continue }
                found[id] = AppRule(id: id, name: (bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String) ?? (bundle.localizedInfoDictionary?["CFBundleName"] as? String) ?? url.deletingPathExtension().lastPathComponent)
            }
        }
        for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
            guard let id = app.bundleIdentifier, id != Bundle.main.bundleIdentifier else { continue }
            found[id] = AppRule(id: id, name: app.localizedName ?? id)
        }
        installed = found.values.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @ObservedObject var engine: FocusEngine
    @State private var page = 2
    @State private var pauseOptions = false
    @State private var moreOptions = false
    @State private var recording = false
    @State private var keyMonitor: Any?
    @State private var presetName = ""
    @State private var savingPreset = false
    var body: some View {
        DesignScreen {
            if page != 0 { BackNavigation { page = 0 } }
            switch page {
            case 1: AppRulesView(store: store)
            case 2: preferencesPage
            default: FocusHome(store: store, engine: engine, openApps: { page = 1 }, openSettings: { page = 2 })
            }
            if let warning = engine.warning { CopyText(text: warning, size: 11, color: .orange) }
            if let message = store.message {
                HStack { CopyText(text: message, size: 11); Spacer(); Button(tr("OK")) { store.message = nil } }
            }
        }.onDisappear { stopRecording() }
            .alert(tr("Save preset"), isPresented: $savingPreset) {
                TextField(tr("Name"), text: $presetName)
                Button(tr("Cancel"), role: .cancel) {}
                Button(tr("Save")) {
                    let name = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    store.preferences.presets.append(Preset(name: String(name.prefix(40)), mode: store.preferences.mode, blur: store.preferences.blur, dim: store.preferences.dim))
                }
            }
    }
    private var preferencesPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                CopyText(text: tr("Set it. Forget it."), size: 27, weight: "Medium", tracking: -1).frame(minHeight: 33)
                CopyText(text: tr("A few details. Then back to your work."), size: 12, color: tone(0x777777, 0xABABAB)).frame(minHeight: 15)
            }
            VStack(alignment: .leading, spacing: 12) {
                eyebrow("BACKGROUND EFFECT")
                HStack(spacing: 8) {
                    ForEach(EffectMode.allCases) { mode in
                        let selected = store.preferences.mode == mode
                        Button { store.preferences.mode = mode } label: {
                            VStack(spacing: 8) {
                                PencilIcon(name: mode == .blur ? "droplets" : mode == .dim ? "moon" : "blend", size: 19)
                                CopyText(text: mode.title, size: 11).frame(minHeight: 13)
                            }.frame(maxWidth: .infinity).frame(height: 74)
                                .background(selected ? tone(0xF1F1F1, 0x373737) : paper, in: RoundedRectangle(cornerRadius: 7))
                                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(selected ? tone(0x222222, 0xCCCCCC) : tone(0xE5E5E5, 0x484848), lineWidth: 1))
                        }.buttonStyle(.plain)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                eyebrow("MAKE IT AUTOMATIC")
                setting("Launch at login", detail: "Ready when your Mac is.", value: Binding(get: { store.loginEnabled }, set: store.setLogin))
                setting("Focus across all displays", detail: "One workspace, fewer distractions.", value: $store.preferences.allDisplays)
                setting("Keep split windows clear", detail: "Work with two windows, side by side.", value: $store.preferences.keepTiled)
            }
            VStack(spacing: 16) {
                Button { pauseOptions.toggle() } label: {
                    HStack(spacing: 10) {
                        PencilIcon(name: "pause")
                        VStack(alignment: .leading, spacing: 5) {
                            CopyText(text: tr("Know when to step aside"), weight: "Medium", color: tone(0x252525, 0xE2E2E2)).frame(minHeight: 15)
                            CopyText(text: tr("Full screen & screen sharing"), size: 10, color: secondary).frame(minHeight: 12)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        PencilIcon(name: "chevron-right", size: 16, color: secondary).rotationEffect(.degrees(pauseOptions ? 90 : 0))
                    }
                }.buttonStyle(.plain)
                if pauseOptions {
                    setting("Pause in full screen", detail: "Leave presentations and videos clear.", value: $store.preferences.pauseFullscreen)
                    setting("Pause during screen sharing", detail: "Includes continuous capture and mirrored displays.", value: $store.preferences.pauseScreenSharing)
                }
            }
            HStack {
                CopyText(text: tr("Keyboard shortcut"))
                Spacer(minLength: 8)
                Button(recording ? tr("Press shortcut. Esc cancels.") : Shortcut.label(key: store.preferences.shortcutKey, modifiers: store.preferences.shortcutModifiers, spacing: "  ")) { startRecording() }
                    .font(inter(13)).buttonStyle(.plain).padding(.horizontal, 12).padding(.vertical, 8)
                    .background(tone(0xF3F3F3, 0x393939), in: RoundedRectangle(cornerRadius: 5))
            }.frame(minHeight: 32).padding(.vertical, 17)
                .overlay(alignment: .top) { Rectangle().fill(rowLine).frame(height: 1) }
                .overlay(alignment: .bottom) { Rectangle().fill(rowLine).frame(height: 1) }
            VStack(spacing: 16) {
                Button { moreOptions.toggle() } label: {
                    HStack {
                        CopyText(text: tr("More options"), color: tone(0x777777, 0xAAAAAA)).frame(minHeight: 15)
                        Spacer()
                        PencilIcon(name: "plus", size: 15, color: secondary).rotationEffect(.degrees(moreOptions ? 45 : 0))
                    }
                }.buttonStyle(.plain)
                if moreOptions { advancedOptions }
            }
            HStack(alignment: .top, spacing: 10) {
                PencilIcon(name: "shield-check", color: tone(0x777777, 0xAAAAAA))
                CopyText(text: tr("No recordings. No uploads. Everything stays on your Mac.").replacingOccurrences(of: ". Everything", with: ".\nEverything"), size: 11, color: tone(0x777777, 0xAAAAAA))
                    .lineSpacing(4.4).frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
            }.padding(15).background(tone(0xF6F6F6, 0x303030), in: RoundedRectangle(cornerRadius: 8))
        }
    }
    private var advancedOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            setting("Shake cursor to toggle", detail: "Move quickly from side to side.", value: $store.preferences.shakeToToggle)
            labeledSlider("Blur", value: $store.preferences.blur)
            labeledSlider("Dim", value: $store.preferences.dim)
            ForEach(store.preferences.presets) { preset in
                HStack {
                    Button(L10n.presetName(preset)) { store.preferences.apply(preset) }.buttonStyle(.plain)
                    Spacer()
                    Button {
                        guard let i = store.preferences.presets.firstIndex(where: { $0.id == preset.id }) else { return }
                        store.preferences.presets[i].mode = store.preferences.mode
                        store.preferences.presets[i].blur = store.preferences.blur
                        store.preferences.presets[i].dim = store.preferences.dim
                    } label: { Image(systemName: "arrow.triangle.2.circlepath") }.help(tr("Update preset"))
                    Button { store.preferences.presets.removeAll { $0.id == preset.id } } label: { Image(systemName: "minus.circle") }.help(tr("Remove preset"))
                }.font(inter(12))
            }
            Button(tr("Save preset")) { presetName = ""; savingPreset = true }
        }
    }
    private func eyebrow(_ key: String) -> some View {
        CopyText(text: tr(key), size: 9, color: secondary, tracking: 1).frame(minHeight: 11)
    }
    private func labeledSlider(_ key: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { CopyText(text: tr(key)); Spacer(); Text(value.wrappedValue / 100, format: .percent.precision(.fractionLength(0))).font(inter(12)) }
            PencilSlider(value: value, title: tr(key))
        }
    }
    private func setting(_ title: String, detail: String, value: Binding<Bool>) -> some View {
        Toggle(isOn: value) {
            VStack(alignment: .leading, spacing: 5) {
                CopyText(text: tr(title), weight: "Medium", color: tone(0x252525, 0xE2E2E2)).frame(minHeight: 15)
                CopyText(text: tr(detail), size: 10, color: secondary).frame(minHeight: 12)
            }
        }.toggleStyle(PencilSwitchStyle()).padding(.vertical, 16)
            .overlay(alignment: .bottom) { Rectangle().fill(rowLine).frame(height: 1) }
            .accessibilityLabel(tr(title)).accessibilityHint(tr(detail))
    }
    private func startRecording() {
        guard !recording else { stopRecording(); return }
        recording = true
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { stopRecording(); return nil }
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard !flags.intersection([.command, .option, .control]).isEmpty else { return nil }
            store.preferences.shortcutKey = UInt32(event.keyCode)
            store.preferences.shortcutModifiers = Shortcut.carbonFlags(flags)
            stopRecording()
            return nil
        }
    }
    private func stopRecording() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }; keyMonitor = nil; recording = false
    }
}
