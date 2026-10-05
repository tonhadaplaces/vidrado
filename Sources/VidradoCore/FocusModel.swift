import Foundation
import CoreGraphics

public enum EffectMode: String, Codable, CaseIterable, Identifiable {
    case blur, dim, both
    public var id: String { rawValue }
    public var title: String {
        switch self { case .blur: return L10n.text("Blur"); case .dim: return L10n.text("Dim"); case .both: return L10n.text("Both") }
    }
}

public struct Preset: Codable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var symbol: String
    public var mode: EffectMode
    public var blur: Double
    public var dim: Double
    public init(id: String = UUID().uuidString, name: String, symbol: String = "slider.horizontal.3", mode: EffectMode, blur: Double, dim: Double) {
        self.id = id; self.name = name; self.symbol = symbol; self.mode = mode; self.blur = blur; self.dim = dim
    }
    public static let defaults: [Preset] = [
        .init(id: "coding", name: "Programar", symbol: "chevron.left.forwardslash.chevron.right", mode: .both, blur: 72, dim: 42),
        .init(id: "reading", name: "Ler", symbol: "book", mode: .blur, blur: 88, dim: 28),
        .init(id: "presenting", name: "Apresentar", symbol: "rectangle.on.rectangle", mode: .dim, blur: 40, dim: 52),
        .init(id: "deep", name: "Foco profundo", symbol: "moon.stars", mode: .both, blur: 90, dim: 62)
    ]
}

public struct AppRule: Codable, Identifiable, Equatable {
    public var id: String // Bundle identifier, never a transient PID.
    public var name: String
    public init(id: String, name: String) { self.id = id; self.name = name }
}

public struct Preferences: Codable, Equatable {
    public var enabled = true
    public var mode: EffectMode = .both
    public var blur = 55.0
    public var dim = 25.0
    public var allDisplays = true
    public var keepTiled = true
    public var pauseFullscreen = true
    public var pauseScreenSharing = true
    public var shakeToToggle = false
    public var shortcutKey: UInt32 = 11 // B
    public var shortcutModifiers: UInt32 = 2304 // command + option (Carbon)
    public var sharpApps: [AppRule] = []
    public var excludedApps: [AppRule] = []
    public var presets: [Preset] = Preset.defaults
    public init() {}
    public var blurRadius: Int { mode == .dim ? 0 : Int(Self.clamp(blur) * 0.6) }
    public var dimOpacity: Double { mode == .blur ? 0 : Self.clamp(dim) / 100 * 0.85 }
    public mutating func apply(_ preset: Preset) { mode = preset.mode; blur = Self.clamp(preset.blur); dim = Self.clamp(preset.dim) }
    public mutating func sanitize() {
        blur = Self.clamp(blur); dim = Self.clamp(dim)
        if shortcutKey > 127 { shortcutKey = 11 }
        if shortcutModifiers & 0x1900 == 0 { shortcutModifiers = 2304 }
        presets = presets.map { var p = $0; p.blur = Self.clamp(p.blur); p.dim = Self.clamp(p.dim); return p }
    }
    private static func clamp(_ value: Double) -> Double { value.isFinite ? min(100, max(0, value)) : 0 }
}

public struct WindowInfo: Equatable {
    public var id: UInt32
    public var pid: Int32
    public var bundleID: String
    public var bounds: CGRect // WindowServer coordinates: top left of primary display.
    public var layer: Int
    public init(id: UInt32, pid: Int32, bundleID: String = "", bounds: CGRect, layer: Int = 0) {
        self.id = id; self.pid = pid; self.bundleID = bundleID; self.bounds = bounds; self.layer = layer
    }
}

public enum FocusGeometry {
    /// Non-overlapping rectangular remainder, used for the WindowServer's clip region.
    public static func subtract(_ hole: CGRect, from rect: CGRect) -> [CGRect] {
        let cut = rect.intersection(hole)
        guard !cut.isNull, !cut.isEmpty else { return [rect] }
        return [
            CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: cut.minY - rect.minY),
            CGRect(x: rect.minX, y: cut.maxY, width: rect.width, height: rect.maxY - cut.maxY),
            CGRect(x: rect.minX, y: cut.minY, width: cut.minX - rect.minX, height: cut.height),
            CGRect(x: cut.maxX, y: cut.minY, width: rect.maxX - cut.maxX, height: cut.height)
        ].filter { $0.width > 0 && $0.height > 0 }
    }
    public static func subtract(_ holes: [CGRect], from rect: CGRect) -> [CGRect] {
        holes.reduce([rect]) { pieces, hole in pieces.flatMap { subtract(hole, from: $0) } }
    }
    public static func appKitFrame(_ rect: CGRect, primaryHeight: CGFloat) -> CGRect {
        CGRect(x: rect.minX, y: primaryHeight - rect.maxY, width: rect.width, height: rect.height)
    }
    public static func isFullscreen(_ window: CGRect, display: CGRect) -> Bool {
        abs(window.minX - display.minX) <= 2 && abs(window.minY - display.minY) <= 2 &&
        abs(window.width - display.width) <= 2 && abs(window.height - display.height) <= 2
    }
    public static func isTiledNeighbor(_ candidate: CGRect, active: CGRect, visibleDisplay: CGRect) -> Bool {
        guard visibleDisplay.contains(CGPoint(x: candidate.midX, y: candidate.midY)),
              visibleDisplay.contains(CGPoint(x: active.midX, y: active.midY)) else { return false }
        let tall = active.height >= visibleDisplay.height * 0.87 && candidate.height >= visibleDisplay.height * 0.87
        let aligned = abs(active.minY - candidate.minY) <= 16 && abs(active.maxY - candidate.maxY) <= 16
        let adjacent = min(abs(active.maxX - candidate.minX), abs(candidate.maxX - active.minX)) <= 20
        let fills = active.union(candidate).width >= visibleDisplay.width * 0.9
        return tall && aligned && adjacent && fills && active.intersection(candidate).width <= 2
    }
    /// Only visible portions of pinned windows remain sharp; occluding windows must still be softened.
    public static func sharpRegions(windows: [WindowInfo], active: WindowInfo, sharpBundles: Set<String>, keepTiled: Bool, visibleDisplay: CGRect) -> [CGRect] {
        windows.enumerated().flatMap { index, window -> [CGRect] in
            guard window.id != active.id, window.layer == 0,
                  sharpBundles.contains(window.bundleID) || (keepTiled && isTiledNeighbor(window.bounds, active: active.bounds, visibleDisplay: visibleDisplay)) else { return [] }
            return subtract(windows.prefix(index).filter { $0.layer == 0 }.map(\.bounds), from: window.bounds)
        }
    }
}

public enum PauseReason: String {
    case off = "Foco desativado"
    case desktop = "Nenhuma janela em foco"
    case excluded = "Aplicativo excluído"
    case fullscreen = "Pausa em tela cheia"
    case sharing = "Pausa durante compartilhamento"
    case session = "Sessão inativa"
}

public enum FocusPolicy {
    public static func pause(preferences: Preferences, active: WindowInfo?, displays: [CGRect], sharing: Bool, sessionActive: Bool, fullscreenSpace: Bool = false) -> PauseReason? {
        if !preferences.enabled { return .off }
        if !sessionActive { return .session }
        if preferences.pauseScreenSharing && sharing { return .sharing }
        guard let active else { return .desktop }
        if preferences.excludedApps.contains(where: { $0.id == active.bundleID }) { return .excluded }
        if preferences.pauseFullscreen && (fullscreenSpace || displays.contains(where: { FocusGeometry.isFullscreen(active.bounds, display: $0) })) { return .fullscreen }
        return nil
    }
}

public struct ShakeDetector {
    private var last: CGPoint?
    private var direction: CGFloat = 0
    private var reversals: [TimeInterval] = []
    private var distance: CGFloat = 0
    private var lastMovement: TimeInterval = 0
    private var lastToggle: TimeInterval = -.infinity
    public init() {}
    public mutating func sample(_ point: CGPoint, at time: TimeInterval) -> Bool {
        defer { last = point }
        guard let last, time - lastToggle > 1.5 else { return false }
        let dx = point.x - last.x
        guard abs(dx) > 12 else { return false }
        if time - lastMovement > 0.35 { reversals = []; distance = 0; direction = 0 }
        lastMovement = time
        distance += abs(dx)
        let next: CGFloat = dx > 0 ? 1 : -1
        if direction != 0 && next != direction { reversals.append(time) }
        direction = next
        reversals.removeAll { time - $0 > 0.65 }
        if reversals.count >= 4 && distance > 320 {
            lastToggle = time; reversals = []; distance = 0; direction = 0
            return true
        }
        return false
    }
}
