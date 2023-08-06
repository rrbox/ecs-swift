// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

struct Module {
    let name: String
    let path: String?
    
    init(name: String, path: String? = nil) {
        self.name = name
        self.path = path
    }
    
    var dependency: Target.Dependency {
        Target.Dependency(stringLiteral: self.name)
    }
    
}

extension Module {
    static let ecs = Module(name: "ECS")
    static let plugIns = Module(name: "PlugIns")
    static let keyboard = Module(name: "ECS_Keyboard", path: "Sources/PlugIns/Keyboard")
    static let mouse = Module(name: "ECS_Mouse", path: "Sources/PlugIns/Mouse")
    static let objectLink = Module(name: "ECS_ObjectLink", path: "Sources/PlugIns/ObjectLink")
    static let scene = Module(name: "ECS_Scene", path: "Sources/PlugIns/Scene")
    static let scroll = Module(name: "ECS_Scroll", path: "Sources/PlugIns/Scroll")
    
    static let ecs_swiftTests = Module(name: "ecs-swiftTests")
    static let keyBoardPlugInTests = Module(name: "KeyBoardPlugInTests")
    static let mousePlugInTests = Module(name: "MousePlugInTests")
    static let objectLinkPlugInTests = Module(name: "ObjectLinkPlugInTests")
    static let scenePlugInTests = Module(name: "ScenePlugInTests")
    static let scrollPlugInTests = Module(name: "ScrollPlugInTests")
}

let package = Package(
    name: "ECS_Swift",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: Module.ecs.name,
            targets: [Module.ecs.name]),
        .library(
            name: Module.plugIns.name,
            targets: [
                Module.keyboard.name,
                Module.mouse.name,
                Module.objectLink.name,
                Module.scene.name,
                Module.scroll.name,
            ]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: Module.ecs.name,
            dependencies: []),
        .target(
            name: Module.keyboard.name,
            dependencies: [Module.ecs.dependency],
            path: Module.keyboard.path),
        .target(
            name: Module.mouse.name,
            dependencies: [Module.ecs.dependency],
            path: Module.mouse.path),
        .target(
            name: Module.objectLink.name,
            dependencies: [Module.ecs.dependency],
            path: Module.objectLink.path),
        .target(
            name: Module.scene.name,
            dependencies: [Module.ecs.dependency],
            path: Module.scene.path),
        .target(
            name: Module.scroll.name,
            dependencies: [Module.ecs.dependency],
            path: Module.scroll.path),
        .testTarget(
            name: Module.ecs_swiftTests.name,
            dependencies: [Module.ecs.dependency]),
        .testTarget(
            name: Module.keyBoardPlugInTests.name,
            dependencies: [Module.keyboard.dependency]),
        .testTarget(
            name: Module.mousePlugInTests.name,
            dependencies: [Module.mouse.dependency]),
        .testTarget(
            name: Module.objectLinkPlugInTests.name,
            dependencies: [Module.objectLink.dependency]),
        .testTarget(
            name: Module.scenePlugInTests.name,
            dependencies: [Module.scene.dependency]),
        .testTarget(
            name: Module.scrollPlugInTests.name,
            dependencies: [Module.scroll.dependency]),
    ]
)
