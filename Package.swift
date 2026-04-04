// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YFLog",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "YFLog",
            targets: ["YFLog"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.11.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
      .binaryTarget(name: "mars",
                    url: "https://github.com/jgh33/YFLog/releases/download/0.0.3/mars.xcframework.zip",
                    checksum: "148c14c9f843e731ef5aa6e5a3b998c48ba8ba8f0842fe3a3b3c1df2161e2d19"
      ),
//      .binaryTarget(name: "mars",
//                    path: "mars.xcframework"),
      .target(name: "Bridge",
              dependencies: ["mars"],
              path: "Sources/Bridge",
              publicHeadersPath: "include",
//              linkerSettings: [.linkedLibrary("z")],
      ),
      .target(name: "YFLog",
              dependencies: [
                "Bridge",
                 .product(name: "Logging", package: "swift-log")
              ],
      ),
      .testTarget(name: "YFLogTests",
                  dependencies: ["YFLog"]
      ),
        
    ]
)
