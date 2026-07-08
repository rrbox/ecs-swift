//
//  SearchedEntityCommands.swift
//
//
//  Created by rrbox on 2024/02/18.
//

final public class SearchedEntityCommands: EntityCommands {
    /// searched entity 用のビルダーを生成します。
    ///
    /// 蓄積先の queue は World のオプションにより異なります:
    /// 旧経路は `SearchedEntityCommandQueue`、archetype storage ON の World では
    /// `SearchedEntityDiffQueue` が渡されます(要件 3-2。公開 API は共通)。
    override init(entity: Entity, commandsQueue: EntityCommandsQueue) {
        super.init(entity: entity, commandsQueue: commandsQueue)
    }
}
