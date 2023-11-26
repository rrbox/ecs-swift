//
//  StateControll.swift
//
//
//  Created by rrbox on 2023/10/28.
//

/**
 ``World`` の状態管理をシステムから行います.
 
 - note: 詳細は <doc:States> を参照してください.
 */

final public class State<T: StateProtocol>: SystemParameter {
    let stateStrageRef: StateStorage
    let currentState: T
    
    init?(stateStrageRef: StateStorage, currentStaete: T?) {
        guard let currentStaete = currentStaete else { return nil }
        self.stateStrageRef = stateStrageRef
        self.currentState = currentStaete
    }
    
    public static func register(to worldStorage: WorldStorageRef) {
        
    }
    
    public static func getParameter(from worldStorage: WorldStorageRef) -> State<T>? {
        State<T>(stateStrageRef: worldStorage.stateStorage,
                 currentStaete: worldStorage.stateStorage.currentState(ofType: T.self))
    }
    
    /**
     別の状態へ遷移します.
     - Parameter state: 遷移先の `State` を指定します.
     */
    public func enter(_ state: T) {
        self.stateStrageRef.enter(state)
    }
    
    /**
     現在の状態を inactive にして, 別の状態へ遷移します.
     - Parameter state: 遷移先の `State` を指定します.
     
     - `state` の ``Schedule/didEnter(_:)`` と関連づけられたシステムが実行されます.
     - 以前の状態の ``Schedule/onPause(_:)`` と関連づけられたシステムが実行されます.
     - `state` の ``Schedule/onUpdate(_:)`` と関連づけられたシステムが常時実行されます.
     - 以前の状態の ``Schedule/onInactiveUpdate(_:)`` と関連づけられたシステムが常時実行されます.
     - 以前の状態および `state` の ``Schedule/onStackUpdate(_:)`` と関連づけられたシステムが常時実行されます.
     */
    public func push(_ state: T) {
        self.stateStrageRef.push(state)
    }
    
    /**
     1つ前の状態に戻ります.
     
     - 以前(戻り先)の状態の ``Schedule/onResume(_:)`` と関連づけられたシステムが実行されます.
     - 戻り先の状態の ``Schedule/onUpdate(_:)`` と関連づけられたシステムが常時実行されます.     
     - 直前の状態の ``Schedule/willExit(_:)`` と関連づけられたシステムが実行されます.
     - 直前の状態の ``Schedule/onUpdate(_:)`` と関連したシステムが実行しなくなり, 戻り先の状態の ``Schedule/onUpdate(_:)`` のシステムが常時実行されます.
     - 直前の状態の ``Schedule/onStackUpdate(_:)`` のシステムが実行しなくなります. 戻り先の状態の ``Schedule/onStackUpdate(_:)`` のシステムは引き続き常時実行されます.
     */
    public func pop() {
        self.stateStrageRef.pop(T.self)
    }
    
}
