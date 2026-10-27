// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Milo",
    platforms: [.macOS("26.0")],
    products: [.executable(name: "Milo", targets: ["Milo"])],
    targets: [
        .target(name: "MiloCore"),
        .executableTarget(name: "Milo", dependencies: ["MiloCore"]),
        .testTarget(name: "MiloCoreTests", dependencies: ["MiloCore"]),
    ],
    swiftLanguageModes: [.v5]
)
