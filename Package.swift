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
    static let graphic2d = Module(name: "ECS_Graphic", path: "Sources/PlugIns/Graphic2D")
    static let keyboard = Module(name: "ECS_Keyboard", path: "Sources/PlugIns/Keyboard")
    static let mouse = Module(name: "ECS_Mouse", path: "Sources/PlugIns/Mouse")
    static let objectLink = Module(name: "ECS_ObjectLink", path: "Sources/PlugIns/ObjectLink")
    static let scene = Module(name: "ECS_Scene", path: "Sources/PlugIns/Scene")
    static let scroll = Module(name: "ECS_Scroll", path: "Sources/PlugIns/Scroll")
    
    static let ecs_swiftTests = Module(name: "ecs-swiftTests")
    static let graphicPlugInTests = Module(name: "GraphicPlugInTests")
    static let keyBoardPlugInTests = Module(name: "KeyBoardPlugInTests")
    static let mousePlugInTests = Module(name: "MousePlugInTests")
    static let objectLinkPlugInTests = Module(name: "ObjectLinkPlugInTests")
    static let scenePlugInTests = Module(name: "ScenePlugInTests")
    static let scrollPlugInTests = Module(name: "ScrollPlugInTests")
}

extension Target {
    static func target(module: Module, dependencies: [Module]) -> Target {
        .target(
            name: module.name,
            dependencies: dependencies.map { $0.dependency },
            path: module.path)
    }
    
    static func testTarget(module: Module, dependencies: [Module]) -> Target {
        .testTarget(
            name: module.name,
            dependencies: dependencies.map { $0.dependency },
            path: module.path
        )
    }
}

let package = Package(
    name: "ECS_Swift",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: Module.ecs.name,
            targets: [Module.ecs.name]),
        .library(
            name: Module.plugIns.name,
            targets: [
                Module.graphic2d.name,
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
            module: .ecs,
            dependencies: []),
        .target(
            module: .graphic2d,
            dependencies: [.ecs]),
        .target(
            module: .keyboard,
            dependencies: [.ecs]),
        .target(
            module: .mouse,
            dependencies: [.ecs]),
        .target(
            module: .objectLink,
            dependencies: [.ecs]),
        .target(
            module: .scene,
            dependencies: [.ecs]),
        .target(
            module: .scroll,
            dependencies: [.ecs]),
        .testTarget(
            module: .ecs_swiftTests,
            dependencies: [.ecs]),
        .testTarget(
            module: .graphicPlugInTests,
            dependencies: [.graphic2d]),
        .testTarget(
            module: .keyBoardPlugInTests,
            dependencies: [.keyboard]),
        .testTarget(
            module: .mousePlugInTests,
            dependencies: [.mouse]),
        .testTarget(
            module: .objectLinkPlugInTests,
            dependencies: [.objectLink]),
        .testTarget(
            module: .scenePlugInTests,
            dependencies: [.scene]),
        .testTarget(
            module: .scrollPlugInTests,
            dependencies: [.scroll]),
    ]
)
