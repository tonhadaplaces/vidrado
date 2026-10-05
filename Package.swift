// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Vidrado",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Vidrado", targets: ["Vidrado"])],
    targets: [
        .target(name: "VidradoCore", resources: [.process("Resources")]),
        .executableTarget(name: "Vidrado", dependencies: ["VidradoCore"]),
        .testTarget(name: "VidradoCoreTests", dependencies: ["VidradoCore"])
    ]
)
