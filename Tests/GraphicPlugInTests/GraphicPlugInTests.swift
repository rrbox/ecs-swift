//
//  GraphicPlugInTests.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

@testable import ECS
@testable import ECS_Graphic
import SpriteKit
import XCTest

func XCTAssertStepOrder(
    currentStep: Int,
    steps: inout [Int],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let stepCount = steps.count
    var targetSteps = [Int](repeating: 0, count: stepCount)
    for i in 0 ... currentStep {
        targetSteps[i] += 1
    }
    steps[currentStep] += 1
    XCTAssertEqual(targetSteps, steps, file: file, line: line)
}

@MainActor
final class GraphicPlugInTests: XCTestCase {
    func testSetGraphic() {
        let scene = SKScene() // 画面
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands, nodes: Resource<Nodes>) in
                let node = SKNode()
                commands.spawn()
                    .setGraphic(nodes.resource.create(node: node))
            }

        world.setUpWorld()
        world.update(currentTime: -1) // first frame state
        XCTAssertEqual(scene.children.count, 1)
    }

    func testAddChildOnUpdate() {
        let scene = SKScene()
        let parentNode = SKNode()
        var flags = [0, 0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.update) { (commands: Commands, currentTime: Resource<CurrentTime>, nodes: Resource<Nodes>) in
                if currentTime.resource.value == 0 {
                    let childNode = SKNode()
                    let child = commands.spawn()
                        .setGraphic(nodes.resource.create(node: childNode))
                        .id()
                    commands.spawn()
                        .setGraphic(nodes.resource.create(node: parentNode))
                        .addChild(child)
                }
            }
            .addSystem(.update) { (
                children: Query<Child>,
                parents: Query3<Entity, Parent, Graphic<SKNode>>,
                currentTime: Resource<CurrentTime>,
                commands: Commands,
                nodes: Resource<Nodes>
            ) in
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しない.
                case 0:
                    XCTAssertEqual(parents.components.data.count, 0)
                    XCTAssertEqual(parentNode.children.count, 0)
                    XCTAssertEqual(children.components.data.count, 0)
                    XCTAssertEqual(nodes.resource.store.count, 2)
                    flags[0] += 1
                case 1:
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(parentNode.children.count, 1)
                    XCTAssertEqual(children.components.data.count, 1)
                    XCTAssertEqual(nodes.resource.store.count, 2)
                    flags[1] += 1
                default: return
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1) // first frame state
        world.update(currentTime: 0) // update: ここで graphic system が実行される
        world.update(currentTime: 1)
        XCTAssertEqual(parentNode.children.count, 1)
        XCTAssertEqual(flags, [1, 1])
    }

    func testAddChildIfNotHasNode() {
        let scene = SKScene()
        var flags = [0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands, nodes: Resource<Nodes>) in
                // set graphic されていない entity に対して addChild を動かす
                let childNode_0 = SKNode()
                let childNode_1 = SKNode()

                let child_0 = commands.spawn()
                    .setGraphic(nodes.resource.create(node: childNode_0))
                    .id()
                commands.spawn()
                    .addChild(child_0)

                let child_1 = commands.spawn()
                    .id()
                commands.spawn()
                    .setGraphic(nodes.resource.create(node: childNode_1))
                    .addChild(child_1)
            }
            .addSystem(.update) { (
                children: Query<Child>,
                parents: Query2<Entity, Parent>,
                nodes: Resource<Nodes>
            ) in
                flags[0] += 1
                XCTAssertEqual(parents.components.data.count, 2)
                XCTAssertEqual(children.components.data.count, 0)
                XCTAssertEqual(nodes.resource.store.count, 2)
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)

        XCTAssertEqual(flags, [2])

    }

    // entity hierarchy から取り外す処理のテスト
    func testRemoveFromParent() {
        let scene = SKScene()
        let parentNode = SKNode()
        var flags = [0, 0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands, nodes: Resource<Nodes>) in
                let childNode = SKNode()

                let child = commands.spawn()
                    .setGraphic(nodes.resource.create(node: childNode))
                    .id()
                commands.spawn()
                    .setGraphic(nodes.resource.create(node: parentNode))
                    .addChild(child)
            }
            .addSystem(.update) { (children: Query<Child>, parents: Query2<Entity, Parent>, currentTime: Resource<CurrentTime>) in
                // add child 関数が機能しているのかをチェック
                XCTAssertEqual(parents.components.data.count, 2)
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しない.
                case 0:
                    flags[0] += 1
                    XCTAssertEqual(parentNode.children.count, 1)
                    XCTAssertEqual(children.components.data.count, 1)
                default: return
                }
            }
            .addSystem(.update) { (
                children: Filtered<Query<Entity>,
                With<Child>>,
                parents: Query<Parent>,
                commands: Commands,
                currentTime: Resource<CurrentTime>,
                nodes: Resource<Nodes>
            ) in
                // remove from parent 関数の効果をチェック
                XCTAssertEqual(parents.components.data.count, 2)
                switch currentTime.resource.value {
                case 1:
                    flags[1] += 1
                    children.update { entity in
                        commands.entity(entity)
                            .removeFromParent()
                    }
                case 2:
                    flags[1] += 1
                    XCTAssertEqual(children.query.components.data.count, 0)
                    XCTAssertEqual(parentNode.children.count, 0)
                    XCTAssertEqual(nodes.resource.store.count, 1)
                default: break
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1) // この一番最後で _remove from parent tarnsaction 追加
        world.update(currentTime: 2) // remove from parent system 実行, 一番最後に component に変更反映 | ここで結果が出る

        XCTAssertEqual(flags, [1, 2])
    }

    // SKNode が紐づけられた Entity がデスポーンするときの挙動をてすと
    func testParentDespawn() {
        // デスポーンする entity の子 entity もデスポーンする.
        let scene = SKScene()
        let parent = SKNode()
        var flags = [0, 0, 0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands, nodes: Resource<Nodes>) in
                let grandChildNode = SKNode()
                let childNode = SKNode()

                let grandchild = commands.spawn()
                    .setGraphic(nodes.resource.create(node: grandChildNode))
                    .id()
                let child = commands.spawn()
                    .setGraphic(nodes.resource.create(node: childNode))
                    .addChild(grandchild)
                    .id()
                commands.spawn()
                    .setGraphic(nodes.resource.create(node: parent))
                    .addChild(child)
            }
            .addSystem(.update) { (
                currentTime: Resource<CurrentTime>,
                commands: Commands,
                children: Query<Child>,
                parents: Query2<Entity, Parent>,
                totalEntities: Query<Entity>,
                nodes: Resource<Nodes>
            ) in
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しません.
                case 0:
                    flags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 3)
                    XCTAssertEqual(children.components.data.count, 2)
                    XCTAssertEqual(totalEntities.components.data.count, 3)
                    XCTAssertEqual(nodes.resource.store.count, 3)
                case 1:
                    flags[1] += 1
                    parents.update { entity, parent in
                        if parent.children.count == 1 {
                            commands.despawn(entity: entity)
                        }
                    }

                    XCTAssertEqual(parents.components.data.count, 3)
                    XCTAssertEqual(children.components.data.count, 2)
                    XCTAssertEqual(totalEntities.components.data.count, 3)
                    XCTAssertEqual(nodes.resource.store.count, 3)
                case 2:
                    flags[2] += 1
                    XCTAssertEqual(parents.components.data.count, 0)
                    XCTAssertEqual(children.components.data.count, 0)
                    XCTAssertEqual(totalEntities.components.data.count, 0)
                    XCTAssertEqual(nodes.resource.store.count, 0)
                default:
                    fatalError()
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        XCTAssertEqual(flags, [1, 1, 1])
    }

    // 子 entity をデスポーンすると、親から観測されなくなります.
    func testChildDespaen() {
        let scene = SKScene()
        var flags = [0, 0, 0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands, nodes: Resource<Nodes>) in
                let childNode = SKNode()
                let parentNode = SKNode()
                let child = commands.spawn()
                    .setGraphic(nodes.resource.create(node: childNode))
                    .id()
                commands.spawn()
                    .setGraphic(nodes.resource.create(node: parentNode))
                    .addChild(child)
            }
            .addSystem(.update) { (currentTime: Resource<CurrentTime>, commands: Commands, children: Filtered<Query<Entity>, With<Child>>, parents: Query2<Entity, Parent>, totalEntities: Query<Entity>) in
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しません.
                case 0:
                    XCTAssertStepOrder(currentStep: 0, steps: &flags)
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(children.query.components.data.count, 1)
                    XCTAssertEqual(totalEntities.components.data.count, 2)
                case 1:
                    XCTAssertStepOrder(currentStep: 1, steps: &flags)
                    children.update { entity in
                        commands.despawn(entity: entity)
                    }
                    
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(children.query.components.data.count, 1)
                    XCTAssertEqual(totalEntities.components.data.count, 2)
                case 2:
                    XCTAssertStepOrder(currentStep: 2, steps: &flags)
                    XCTAssertEqual(parents.components.data.count, 1)
                    XCTAssertEqual(children.query.components.data.count, 0)
                    XCTAssertEqual(totalEntities.components.data.count, 1)
                default:
                    fatalError() // ここは通過しません.
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)

        XCTAssertEqual(flags, [1, 1, 1])
    }

    func testExclusiveControl() {
        let scene = SKScene()
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands, nodes: Resource<Nodes>) in
                let child = commands.spawn()
                    .setGraphic(nodes.resource.create(node: SKNode()))
                    .id()
                commands.spawn()
                    .setGraphic(nodes.resource.create(node: SKNode()))
                    .addChild(child)
            }
            .addSystem(.update, { (graphic: Query2<Entity, Graphic<SKNode>>, commands: Commands) in
                graphic.update { entity, _ in
                    commands.entity(entity).removeAllChildren()
                }
            })
            .addSystem(.update, { (graphic: Query2<Entity, Graphic<SKNode>>, commands: Commands) in
                graphic.update { entity, _ in
                    commands.despawn(entity: entity)
                }
            })
            .addSystem(.update) { (graphic: Query2<Entity, Graphic<SKNode>>) in
                graphic.update { entity, graphic in
                    graphic.nodeRef.position.x += 1
                }
            }

        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
    }
}
