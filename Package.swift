// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YFLog",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "YFLog",
            targets: ["YFLog"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
      .binaryTarget(name: "mars",
                    url: "https://github.com/jgh33/YFLog/releases/download/0.0.1/mars.xcframework.zip",
                    checksum: "ba7e1bf5b5140d7e10bf574fc42c63c1a78d3c4b147daf5496c6d4f0eeb0814e"
      ),
      .target(name: "Bridge",
              dependencies: ["mars"],
              path: "Sources/Bridge",
              publicHeadersPath: "include",
              linkerSettings: [.linkedLibrary("z")],
      ),
      .target(name: "YFLog",
              dependencies: ["Bridge"],
      ),
      .testTarget(name: "YFLogTests",
                  dependencies: ["YFLog"]
      ),
        
    ]
)
