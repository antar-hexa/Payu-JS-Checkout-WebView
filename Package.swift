// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PayuCheckoutWebview",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "PayuCheckoutWebview",
            targets: ["PayUCheckoutWebViewPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "PayUCheckoutWebViewPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/PayUCheckoutWebViewPlugin"),
        .testTarget(
            name: "PayUCheckoutWebViewPluginTests",
            dependencies: ["PayUCheckoutWebViewPlugin"],
            path: "ios/Tests/PayUCheckoutWebViewPluginTests")
    ]
)