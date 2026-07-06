//
//  ColumnTests.swift
//
//
//  Created by rrbox on 2026/07/06.
//

@testable import ECS
import Testing

struct ColumnTests {

    struct ValueComponent: Component, Equatable {
        let value: Int
    }

    final class Node {
        var value: Int
        init(value: Int) {
            self.value = value
        }
    }

    /// クラス参照を保持する非トリビアルなコンポーネント(Graphic<Node> 相当)。
    struct NodeComponent: Component {
        let node: Node
    }

    @Test func appendThenCountAndDataIntegrity() {
        let column = Column<ValueComponent>()
        #expect(column.count == 0)
        column.append(ValueComponent(value: 10))
        column.append(ValueComponent(value: 20))
        column.append(ValueComponent(value: 30))
        #expect(column.count == 3)
        #expect(column.data == [
            ValueComponent(value: 10),
            ValueComponent(value: 20),
            ValueComponent(value: 30),
        ])
    }

    @Test func moveRowAppendsToTargetAndSwapRemovesFromSource() {
        let source = Column<ValueComponent>()
        source.append(ValueComponent(value: 1))  // a
        source.append(ValueComponent(value: 2))  // b
        source.append(ValueComponent(value: 3))  // c
        let target = Column<ValueComponent>()
        target.append(ValueComponent(value: 100))

        source.moveRow(0, to: target)

        // 移動した値が target 末尾に追加される
        #expect(target.count == 2)
        #expect(target.data == [
            ValueComponent(value: 100),
            ValueComponent(value: 1),
        ])
        // source は swap-remove で [a, b, c] → [c, b] になる
        #expect(source.count == 2)
        #expect(source.data == [
            ValueComponent(value: 3),
            ValueComponent(value: 2),
        ])
    }

    @Test func moveLastRow() {
        let source = Column<ValueComponent>()
        source.append(ValueComponent(value: 1))
        source.append(ValueComponent(value: 2))
        let target = Column<ValueComponent>()

        source.moveRow(1, to: target)

        #expect(source.data == [ValueComponent(value: 1)])
        #expect(target.data == [ValueComponent(value: 2)])
    }

    @Test func swapRemoveRowMovesLastIntoRemovedSlot() {
        let column = Column<ValueComponent>()
        column.append(ValueComponent(value: 1))  // a
        column.append(ValueComponent(value: 2))  // b
        column.append(ValueComponent(value: 3))  // c

        column.swapRemoveRow(0)

        // [a, b, c] → [c, b]
        #expect(column.data == [
            ValueComponent(value: 3),
            ValueComponent(value: 2),
        ])
    }

    @Test func swapRemoveLastRow() {
        let column = Column<ValueComponent>()
        column.append(ValueComponent(value: 1))
        column.append(ValueComponent(value: 2))

        column.swapRemoveRow(1)

        #expect(column.data == [ValueComponent(value: 1)])
    }

    @Test func swapRemoveOnlyRowMakesColumnEmpty() {
        let column = Column<ValueComponent>()
        column.append(ValueComponent(value: 1))

        column.swapRemoveRow(0)

        #expect(column.count == 0)
        #expect(column.data.isEmpty)
    }

    @Test func makeEmptyReturnsSameTypedEmptyColumnUsableAsMoveTarget() throws {
        let source = Column<ValueComponent>()
        source.append(ValueComponent(value: 42))

        let empty = source.makeEmpty()
        #expect(empty.count == 0)
        #expect(empty is Column<ValueComponent>)

        // makeEmpty で生成したカラムを moveRow の移動先として使用できる
        source.moveRow(0, to: empty)
        #expect(source.count == 0)
        let typed = try #require(empty as? Column<ValueComponent>)
        #expect(typed.data == [ValueComponent(value: 42)])
    }

    @Test func classReferencePreservedAcrossMoveRow() {
        let node = Node(value: 0)
        let source = Column<NodeComponent>()
        source.append(NodeComponent(node: node))
        let target = Column<NodeComponent>()

        source.moveRow(0, to: target)

        // 移動後も参照同一性が保たれ、元の参照経由の変更が観測できる
        #expect(target.data[0].node === node)
        node.value = 99
        #expect(target.data[0].node.value == 99)
    }

}
