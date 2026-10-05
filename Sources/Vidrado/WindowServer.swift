import AppKit
import VidradoCore
import Darwin

/// These optional WindowServer entry points provide real, live blur without screen capture.
/// Resolve at runtime: a future macOS can remove them without preventing the app from launching.
final class WindowServer {
    typealias Connection = @convention(c) () -> Int32
    typealias Blur = @convention(c) (Int32, UInt32, Int32) -> Int32
    // Opaque C region handles must not participate in Swift ARC. CGSReleaseRegion owns their disposal.
    typealias NewRegion = @convention(c) (UnsafePointer<CGRect>, Int32, UnsafeMutablePointer<UnsafeMutableRawPointer?>) -> Int32
    typealias ReleaseRegion = @convention(c) (UnsafeMutableRawPointer) -> Int32
    typealias Shape = @convention(c) (Int32, UInt32, CGFloat, CGFloat, UnsafeMutableRawPointer) -> Int32
    typealias Watching = @convention(c) () -> Bool
    typealias ManagedSpaces = @convention(c) (Int32) -> Unmanaged<CFArray>?
    private let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY)
    private(set) var connection: Int32 = 0
    private var blur: Blur?
    private var newRegion: NewRegion?
    private var releaseRegion: ReleaseRegion?
    private var shape: Shape?
    private var watching: Watching?
    private var managedSpaces: ManagedSpaces?
    var supportsBlur: Bool { blur != nil && connection != 0 }
    var supportsShape: Bool { newRegion != nil && releaseRegion != nil && shape != nil }
    var supportsCaptureDetection: Bool { watching != nil }
    var isScreenShared: Bool { watching?() ?? false }
    var supportsSpaceDetection: Bool { managedSpaces != nil }
    func fullscreenWindowIDs() -> Set<UInt32> {
        guard let displays = managedSpaces?(connection)?.takeRetainedValue() as? [[String: Any]] else { return [] }
        var ids = Set<UInt32>()
        for display in displays {
            guard let space = display["Current Space"] as? [String: Any], space["type"] as? Int == 4 else { continue }
            if let id = space["fs_wid"] as? UInt32 { ids.insert(id) }
            if let layout = space["TileLayoutManager"] as? [String: Any], let tiles = layout["TileSpaces"] as? [[String: Any]] {
                for tile in tiles {
                    if let id = tile["TileWindowID"] as? UInt32 { ids.insert(id) }
                }
            }
        }
        return ids
    }

    init() {
        func symbol<T>(_ name: String, _: T.Type) -> T? {
            guard let handle, let pointer = dlsym(handle, name) else { return nil }
            return unsafeBitCast(pointer, to: T.self)
        }
        connection = symbol("CGSMainConnectionID", Connection.self)?() ?? 0
        blur = symbol("CGSSetWindowBackgroundBlurRadius", Blur.self)
        newRegion = symbol("CGSNewRegionWithRectList", NewRegion.self)
        releaseRegion = symbol("CGSReleaseRegion", ReleaseRegion.self)
        shape = symbol("CGSSetWindowShape", Shape.self)
        watching = symbol("SLSIsScreenWatcherPresent", Watching.self)
        managedSpaces = symbol("SLSCopyManagedDisplaySpaces", ManagedSpaces.self)
    }
    @discardableResult func setBlur(window: NSWindow, radius: Int) -> Bool {
        guard let blur else { return radius == 0 }
        return blur(connection, UInt32(window.windowNumber), Int32(radius)) == 0
    }
    func setShape(window: NSWindow, rectangles: [CGRect]) -> Bool {
        guard let newRegion, let releaseRegion, let shape, !rectangles.isEmpty else { return false }
        var region: UnsafeMutableRawPointer?
        let result = rectangles.withUnsafeBufferPointer { newRegion($0.baseAddress!, Int32($0.count), &region) }
        guard result == 0, let region else { return false }
        defer { _ = releaseRegion(region) }
        return shape(connection, UInt32(window.windowNumber), 0, 0, region) == 0
    }

    static func windows() -> [WindowInfo] {
        guard let entries = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else { return [] }
        var bundles: [Int32: String] = [:]
        return entries.compactMap { entry in
            guard let id = entry[kCGWindowNumber as String] as? UInt32,
                  let pid = entry[kCGWindowOwnerPID as String] as? Int32,
                  let layer = entry[kCGWindowLayer as String] as? Int,
                  let dict = entry[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: dict as CFDictionary),
                  (entry[kCGWindowAlpha as String] as? Double ?? 1) > 0,
                  bounds.width > 1, bounds.height > 1 else { return nil }
            let bundle = bundles[pid] ?? NSRunningApplication(processIdentifier: pid)?.bundleIdentifier ?? ""
            bundles[pid] = bundle
            return WindowInfo(id: id, pid: pid, bundleID: bundle, bounds: bounds, layer: layer)
        }
    }
}

final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    init(frame: CGRect) {
        super.init(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        title = "Vidrado Effect"
        isReleasedWhenClosed = false
        isOpaque = false
        backgroundColor = NSColor.black.withAlphaComponent(0.001)
        hasShadow = false
        ignoresMouseEvents = true
        hidesOnDeactivate = false
        isFloatingPanel = false
        level = .normal
        collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle, .fullScreenAuxiliary]
        animationBehavior = .none
        isExcludedFromWindowsMenu = true
    }
}
