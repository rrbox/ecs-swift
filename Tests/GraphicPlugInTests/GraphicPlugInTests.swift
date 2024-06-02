//
//  GraphicPlugInTests.swift
//  
//
//  Created by rrbox on 2023/08/18.
//

@testable import ECS
import ECS_Graphic
import SpriteKit
import XCTest

final class GraphicPlugInTests: XCTestCase {
    func testSetGraphic() {
        let scene = SKScene()
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands) in
                commands.spawn()
                    .setGraphic(SKNode())
            }
        
        world.setUpWorld()
        world.update(currentTime: -1) // first frame state
        world.update(currentTime: 0) // update state
        XCTAssertEqual(scene.children.count, 1)
    }
    
    func testAddChild() {
        let scene = SKScene()
        let parentNode = SKNode()
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.update) { (commands: Commands, currentTime: Resource<CurrentTime>) in
                if currentTime.resource.value == 0 {
                    let child = commands.spawn()
                        .setGraphic(SKNode())
                        .id()
                    commands.spawn()
                        .setGraphic(parentNode)
                        .addChild(child)
                }
            }
            .addSystem(.update) { (children: Query<Child>, parents: Query2<Entity, Parent>, currentTime: Resource<CurrentTime>, commands: Commands) in
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しない.
                case 0:
                    break
                case 1:
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(parentNode.children.count, 1)
                    XCTAssertEqual(children.components.data.count, 0)
                case 2:
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(children.components.data.count, 1)
                default: return
                }
            }
        
        world.setUpWorld()
        world.update(currentTime: -1) // first frame state
        world.update(currentTime: 0) // update つまりここで graphic system が実行される
        world.update(currentTime: 1)
        XCTAssertEqual(parentNode.children.count, 1)
    }
    
    func testAddChildIfNotHasNode() {
        let scene = SKScene()
        var frags = [0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands) in
                let child_0 = commands.spawn()
                    .setGraphic(SKNode())
                    .id()
                commands.spawn()
                    .addChild(child_0)
                
                let child_1 = commands.spawn()
                    .id()
                commands.spawn()
                    .setGraphic(SKNode())
                    .addChild(child_1)
            }
            .addSystem(.update) { (children: Query<Child>, parents: Query2<Entity, Parent>) in
                frags[0] += 1
                XCTAssertEqual(parents.components.data.count, 2)
                XCTAssertEqual(children.components.data.count, 0)
            }
        
        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        
        XCTAssertEqual(frags, [2])
        
    }
    
    // entity hierarchy から取り外す処理のテスト
    func testRemoveFromParent() {
        let scene = SKScene()
        let parentNode = SKNode()
        var frags = [0, 0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands) in
                let child = commands.spawn()
                    .setGraphic(SKNode())
                    .id()
                commands.spawn()
                    .setGraphic(parentNode)
                    .addChild(child)
            }
            .addSystem(.update) { (children: Query<Child>, parents: Query2<Entity, Parent>, currentTime: Resource<CurrentTime>) in
                // add child 関数が機能しているのかをチェック
                XCTAssertEqual(parents.components.data.count, 2)
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しない.
                case 0:
                    frags[0] += 1
                    XCTAssertEqual(parentNode.children.count, 1)
                    XCTAssertEqual(children.components.data.count, 0)
                case 1:
                    frags[0] += 1
                    XCTAssertEqual(children.components.data.count, 1)
                default: return
                }
            }
            .addSystem(.update) { (children: Filtered<Query<Entity>, With<Child>>, parents: Query<Parent>, commands: Commands, currentTime: Resource<CurrentTime>) in
                // remove from parent 関数の効果をチェック
                XCTAssertEqual(parents.components.data.count, 2)
                switch currentTime.resource.value {
                case 2:
                    frags[1] += 1
                    children.update { entity in
                        commands.entity(entity)?
                            .removeFromParent()
                    }
                case 3:
                    frags[1] += 1
                    XCTAssertEqual(children.query.components.data.count, 1)
                    XCTAssertEqual(parentNode.children.count, 0)
                case 4:
                    frags[1] += 1
                    XCTAssertEqual(children.query.components.data.count, 0)
                    XCTAssertEqual(parentNode.children.count, 0)
                default: break
                }
            }
        
        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2) // この一番最後で _remove from parent tarnsaction 追加
        world.update(currentTime: 3) // remove from parent system 実行, 一番最後に component に変更反映
        world.update(currentTime: 4) // ここで結果が出る
        
        XCTAssertEqual(frags, [2, 3])
    }
    
    // SKNode が紐づけられた Entity がデスポーンするときの挙動をてすと
    func testParentDespawn() {
        // デスポーンする entity の子 entity もデスポーンする.
        let scene = SKScene()
        let parent = SKNode()
        var frags = [0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands) in
                let grandchild = commands.spawn()
                    .setGraphic(SKNode())
                    .id()
                let child = commands.spawn()
                    .setGraphic(SKNode())
                    .addChild(grandchild)
                    .id()
                commands.spawn()
                    .setGraphic(parent)
                    .addChild(child)
            }
            .addSystem(.update) { (currentTime: Resource<CurrentTime>, commands: Commands, children: Query<Child>, parents: Query2<Entity, Parent>, totalEntities: Query<Entity>) in
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しません.
                case 0:
                    frags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 3)
                    XCTAssertEqual(children.components.data.count, 0)
                    XCTAssertEqual(totalEntities.components.data.count, 3)
                case 1:
                    frags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 3)
                    XCTAssertEqual(children.components.data.count, 2)
                    XCTAssertEqual(totalEntities.components.data.count, 3)
                case 2:
                    frags[0] += 1
                    parents.update { entity, parent in
                        if parent.children.count == 1 {
                            commands.despawn(entity: entity)
                        }
                    }
                    
                    XCTAssertEqual(parents.components.data.count, 3)
                    XCTAssertEqual(children.components.data.count, 2)
                    XCTAssertEqual(totalEntities.components.data.count, 3)
                case 3:
                    frags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 1)
                    XCTAssertEqual(children.components.data.count, 1)
                    XCTAssertEqual(totalEntities.components.data.count, 1)
                    // このフレームの時だけ、world に存在しない 親を持つ子がいることになる.
                case 4:
                    frags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 0)
                    XCTAssertEqual(children.components.data.count, 0)
                    XCTAssertEqual(totalEntities.components.data.count, 0)
                default:
                    fatalError() // ここは通過しません.
                }
            }
        
        world.setUpWorld()
        world.update(currentTime: -1)
        world.update(currentTime: 0)
        world.update(currentTime: 1)
        world.update(currentTime: 2)
        world.update(currentTime: 3)
        world.update(currentTime: 4)
        
        XCTAssertEqual(frags, [5])
    }
    
    // 子 entity をデスポーンすると、親から観測されなくなります.
    func testChildDespaen() {
        let scene = SKScene()
        var frags = [0]
        let world = World()
            .addResource(SceneResource(scene))
            .addPlugIn(graphicPlugIn(world:))
            .addSystem(.startUp) { (commands: Commands) in
                let child = commands.spawn()
                    .setGraphic(SKNode())
                    .id()
                commands.spawn()
                    .setGraphic(SKNode())
                    .addChild(child)
            }
            .addSystem(.update) { (currentTime: Resource<CurrentTime>, commands: Commands, children: Filtered<Query<Entity>, With<Child>>, parents: Query2<Entity, Parent>, totalEntities: Query<Entity>) in
                switch currentTime.resource.value {
                case -1: fatalError() // ここは通過しません.
                case 0:
                    frags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(children.query.components.data.count, 0)
                    XCTAssertEqual(totalEntities.components.data.count, 2)
                case 1:
                    frags[0] += 1
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(children.query.components.data.count, 1)
                    XCTAssertEqual(totalEntities.components.data.count, 2)
                case 2:
                    frags[0] += 1
                    children.update { entity in
                        commands.despawn(entity: entity)
                    }
                    
                    XCTAssertEqual(parents.components.data.count, 2)
                    XCTAssertEqual(children.query.components.data.count, 1)
                    XCTAssertEqual(totalEntities.components.data.count, 2)
                case 3:
                    frags[0] += 1
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
        world.update(currentTime: 3)
        
        XCTAssertEqual(frags, [4])
    }
}
