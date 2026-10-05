import XCTest
@testable import VidradoCore

final class FocusTests: XCTestCase {
    private let display = CGRect(x: 0, y: 0, width: 1440, height: 900)
    private func window(_ id: UInt32 = 1, _ rect: CGRect = CGRect(x: 100, y: 100, width: 600, height: 500), bundle: String = "app.test") -> WindowInfo {
        WindowInfo(id: id, pid: Int32(id), bundleID: bundle, bounds: rect)
    }
    private func area(_ rectangles: [CGRect]) -> CGFloat { rectangles.reduce(0) { $0 + $1.width * $1.height } }

    func testSubtractionConservesAreaAndHasNoOverlaps() {
        let holes = [CGRect(x: 200, y: 100, width: 300, height: 200), CGRect(x: 400, y: 200, width: 400, height: 300)]
        let pieces = FocusGeometry.subtract(holes, from: display)
        XCTAssertEqual(area(pieces), 1440 * 900 - 60_000 - 120_000 + 10_000)
        for (i, a) in pieces.enumerated() {
            XCTAssertTrue(display.contains(a))
            for b in pieces.dropFirst(i + 1) { XCTAssertTrue(a.intersection(b).isEmpty) }
            for hole in holes { XCTAssertTrue(a.intersection(hole).isEmpty) }
        }
    }
    func testSubtractionHandlesOutsideCoveringAndEdgeTouchingHoles() {
        XCTAssertEqual(FocusGeometry.subtract(CGRect(x: -500, y: 0, width: 500, height: 900), from: display), [display])
        XCTAssertEqual(FocusGeometry.subtract(display.insetBy(dx: -50, dy: -50), from: display), [])
        XCTAssertEqual(area(FocusGeometry.subtract(CGRect(x: -100, y: -100, width: 200, height: 200), from: display)), area([display]) - 10_000)
    }
    func testShapeRegionsStayInGlobalSpaceOnSecondaryDisplays() {
        let builtIn = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let ultrawide = CGRect(x: 1440, y: -300, width: 2560, height: 1200)
        XCTAssertEqual(FocusGeometry.shapeRegion(holes: [], display: builtIn), [builtIn])
        XCTAssertEqual(FocusGeometry.shapeRegion(holes: [], display: ultrawide), [ultrawide])
        let hole = CGRect(x: 1600, y: 0, width: 800, height: 600)
        let regions = FocusGeometry.shapeRegion(holes: [hole], display: ultrawide)
        XCTAssertTrue(regions.allSatisfy { ultrawide.contains($0) })
        XCTAssertEqual(area(regions) + area([ultrawide.intersection(hole)]), area([ultrawide]), accuracy: 0.001)
        XCTAssertEqual(regions.reduce(CGRect.null) { $0.union($1) }.height, ultrawide.height)
    }
    func testMultipleMonitorCoordinatesIncludingAboveAndLeft() {
        let monitors = [CGRect(x: 0, y: 0, width: 1440, height: 900), CGRect(x: -1920, y: 0, width: 1920, height: 1080), CGRect(x: 0, y: -1200, width: 1920, height: 1200)]
        for rect in monitors {
            let native = FocusGeometry.appKitFrame(rect, primaryHeight: 900)
            XCTAssertEqual(FocusGeometry.appKitFrame(native, primaryHeight: 900), rect)
        }
        XCTAssertEqual(FocusGeometry.appKitFrame(monitors[2], primaryHeight: 900).minY, 900)
    }
    func testPinnedAppDoesNotRevealOccludingBackgroundWindows() {
        let active = window(1, CGRect(x: 0, y: 0, width: 500, height: 500))
        let blocker = window(2, CGRect(x: 500, y: 0, width: 200, height: 500))
        let pinned = window(3, CGRect(x: 300, y: 100, width: 600, height: 300), bundle: "app.pinned")
        let holes = FocusGeometry.sharpRegions(windows: [active, blocker, pinned], active: active, sharpBundles: ["app.pinned"], keepTiled: false, visibleDisplay: display)
        XCTAssertEqual(holes, [CGRect(x: 700, y: 100, width: 200, height: 300)])
        XCTAssertTrue(holes.allSatisfy { !$0.intersects(blocker.bounds) })
    }
    func testNoPinnedAppsMeansFullBackgroundEffect() {
        let active = window()
        XCTAssertTrue(FocusGeometry.sharpRegions(windows: [active, window(2)], active: active, sharpBundles: [], keepTiled: false, visibleDisplay: display).isEmpty)
    }
    func testTiledPairIsSharpButOrdinaryNearbyWindowsAreNot() {
        let visible = CGRect(x: 0, y: 25, width: 1440, height: 850)
        let left = CGRect(x: 0, y: 25, width: 715, height: 850)
        let right = CGRect(x: 725, y: 25, width: 715, height: 850)
        XCTAssertTrue(FocusGeometry.isTiledNeighbor(right, active: left, visibleDisplay: visible))
        XCTAssertFalse(FocusGeometry.isTiledNeighbor(right.insetBy(dx: 40, dy: 100), active: left, visibleDisplay: visible))
        XCTAssertFalse(FocusGeometry.isTiledNeighbor(left, active: left, visibleDisplay: visible))
        XCTAssertFalse(FocusGeometry.isTiledNeighbor(CGRect(x: 1440, y: 25, width: 1440, height: 850), active: visible, visibleDisplay: visible))
        let active = window(1, left), neighbor = window(2, right)
        XCTAssertEqual(FocusGeometry.sharpRegions(windows: [active, neighbor], active: active, sharpBundles: [], keepTiled: true, visibleDisplay: visible), [right])
    }
    func testFullscreenDoesNotTreatMaximizedWindowAsFullscreen() {
        XCTAssertTrue(FocusGeometry.isFullscreen(display, display: display))
        XCTAssertFalse(FocusGeometry.isFullscreen(CGRect(x: 0, y: 25, width: 1440, height: 875), display: display))
        XCTAssertTrue(FocusGeometry.isFullscreen(CGRect(x: -1920, y: 0, width: 1920, height: 1080), display: CGRect(x: -1920, y: 0, width: 1920, height: 1080)))
    }
    func testFullscreenSpaceWithVisibleMenuBarPauses() {
        let belowMenu = window(1, CGRect(x: 0, y: 33, width: 1440, height: 867))
        XCTAssertEqual(FocusPolicy.pause(preferences: Preferences(), active: belowMenu, displays: [display], sharing: false, sessionActive: true, fullscreenSpace: true), .fullscreen)
        XCTAssertNil(FocusPolicy.pause(preferences: Preferences(), active: belowMenu, displays: [display], sharing: false, sessionActive: true, fullscreenSpace: false))
    }
    func testPauseRulesAndResume() {
        var p = Preferences()
        func pause(_ active: WindowInfo? = nil, sharing: Bool = false, session: Bool = true) -> PauseReason? {
            FocusPolicy.pause(preferences: p, active: active, displays: [display], sharing: sharing, sessionActive: session)
        }
        XCTAssertNil(pause(window()))
        XCTAssertEqual(pause(), .desktop)
        XCTAssertEqual(pause(window(), sharing: true), .sharing)
        p.pauseScreenSharing = false
        XCTAssertNil(pause(window(), sharing: true))
        XCTAssertEqual(pause(window(1, display)), .fullscreen)
        p.pauseFullscreen = false
        XCTAssertNil(pause(window(1, display)))
        p.excludedApps = [.init(id: "app.test", name: "Test")]
        XCTAssertEqual(pause(window()), .excluded)
        XCTAssertEqual(pause(window(), session: false), .session)
        p.enabled = false
        XCTAssertEqual(pause(window()), .off)
        p.enabled = true; p.excludedApps = []
        XCTAssertNil(pause(window()))
    }
    func testModesAndUntrustedPreferenceBounds() {
        var p = Preferences()
        p.blur = 100; p.dim = 100
        XCTAssertEqual(p.blurRadius, 60); XCTAssertEqual(p.dimOpacity, 0.85)
        p.mode = .dim; XCTAssertEqual(p.blurRadius, 0)
        p.mode = .blur; XCTAssertEqual(p.dimOpacity, 0)
        p.blur = .infinity; p.dim = -30; p.shortcutKey = 999; p.shortcutModifiers = 0
        p.sanitize()
        XCTAssertEqual(p.blur, 0); XCTAssertEqual(p.dim, 0)
        XCTAssertEqual(p.shortcutKey, 11); XCTAssertEqual(p.shortcutModifiers, 2304)
    }
    func testPresetAndPreferencesRoundTrip() throws {
        var p = Preferences()
        for preset in Preset.defaults {
            p.apply(preset)
            XCTAssertEqual(p.mode, preset.mode); XCTAssertEqual(p.blur, preset.blur); XCTAssertEqual(p.dim, preset.dim)
        }
        p.sharpApps = [.init(id: "com.apple.Music", name: "Music")]
        p.presets.append(.init(name: "Meu foco", mode: .both, blur: 43, dim: 22))
        XCTAssertEqual(try JSONDecoder().decode(Preferences.self, from: JSONEncoder().encode(p)), p)
    }
    func testShakeRequiresRapidReversalsAndDebounces() {
        var detector = ShakeDetector()
        XCTAssertFalse(detector.sample(.zero, at: 0))
        var toggles = 0
        for i in 1...10 {
            if detector.sample(CGPoint(x: i % 2 == 0 ? 0 : 100, y: 0), at: Double(i) * 0.08) { toggles += 1 }
        }
        XCTAssertEqual(toggles, 1)
        var slow = ShakeDetector()
        for i in 0...20 { XCTAssertFalse(slow.sample(CGPoint(x: i % 2 == 0 ? 0 : 100, y: 0), at: Double(i))) }
        var straight = ShakeDetector()
        for i in 0...20 { XCTAssertFalse(straight.sample(CGPoint(x: i * 100, y: 0), at: Double(i) * 0.05)) }
    }
    func testSeededRectangleStressCheck() {
        var seed: UInt64 = 54321
        func next(_ max: Int) -> CGFloat { seed = seed &* 6364136223846793005 &+ 1; return CGFloat((seed >> 32) % UInt64(max)) }
        for _ in 0..<150 {
            let hole = CGRect(x: next(1800) - 200, y: next(1200) - 200, width: next(800) + 1, height: next(600) + 1)
            let pieces = FocusGeometry.subtract(hole, from: display)
            let intersection = display.intersection(hole)
            let removed = intersection.isNull ? 0 : intersection.width * intersection.height
            XCTAssertEqual(area(pieces) + removed, area([display]), accuracy: 0.001)
        }
    }
}
