// swift-tools-version:5.4
// Yams 5.1.3（vendored，MIT）— TriFectaSettings 离线依赖
import PackageDescription

let package = Package(
    name: "Yams",
    products: [
        .library(name: "Yams", targets: ["Yams"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CYaml",
            exclude: ["CMakeLists.txt"],
            cSettings: [.define("YAML_DECLARE_STATIC")]
        ),
        .target(
            name: "Yams",
            dependencies: ["CYaml"],
            exclude: ["CMakeLists.txt"],
            cSettings: [.define("YAML_DECLARE_STATIC")]
        )
    ]
)
