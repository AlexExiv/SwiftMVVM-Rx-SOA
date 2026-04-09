// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftMVVM-Rx-SOA",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BaseMVVM",
            targets: ["BaseMVVM"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.7.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.10.1")
    ],
    targets: [
        .target(
            name: "BaseMVVM",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "BaseMVVM",
            exclude: [
                "BaseMVVM.h",
                "Info.plist"
            ],
            resources: [
                .process("UI/Preloader.storyboard"),
                .process("en.lproj"),
                .process("ru.lproj"),
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "BaseMVVMTests",
            dependencies: ["BaseMVVM"],
            path: "BaseMVVMTests",
            exclude: [
                "Info.plist"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
