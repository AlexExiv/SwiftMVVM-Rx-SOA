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
            name: "SwiftMVVM-Rx-SOA",
            targets: ["BaseMVVM"]
        ),
        .library(
            name: "SwiftSOA-API",
            targets: ["SwiftSOAAPI"]
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
                "SwiftSOAAPI",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "BaseMVVM",
            exclude: [
                "BaseMVVM.h",
                "Info.plist",
                "Ext",
                "Repository"
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
        ),
        .target(
            name: "SwiftSOAAPI",
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
            sources: [
                "Ext",
                "Repository"
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
