// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IELTSMaster",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "IELTSCore",
            targets: ["IELTSCore"]
        ),
        .executable(
            name: "IELTSMaster",
            targets: ["IELTSMaster"]
        )
    ],
    targets: [
        .target(
            name: "IELTSCore",
            dependencies: [],
            path: "Sources/IELTSCore",
            resources: [.copy("Resources/Content")],
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]
        ),
        .executableTarget(
            name: "IELTSMaster",
            dependencies: ["IELTSCore"],
            path: "Sources/IELTSMaster",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "IELTSExport",
            dependencies: ["IELTSCore"],
            path: "Sources/IELTSExport"
        ),
        .executableTarget(
            name: "IELTSTestRunner",
            dependencies: ["IELTSCore"],
            path: "Sources/IELTSTestRunner"
        ),
        .testTarget(
            name: "IELTSCoreTests",
            dependencies: ["IELTSCore"],
            path: "Tests/IELTSCoreTests"
        )
    ]
)
