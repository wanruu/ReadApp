//
//  MigrationPlan.swift
//  Read
//
//  Created by wanruuu on 7/9/2024.
//

import Foundation
import SwiftData


enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DataSchemaV1.self, DataSchemaV2.self]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: DataSchemaV1.self,
        toVersion: DataSchemaV2.self,
        willMigrate: { context in
//            let books = try context.fetch(FetchDescriptor<DataSchemaV1.Book>())
            let tags = try context.fetch(FetchDescriptor<DataSchemaV1.Tag>())
            print("will", tags.map({ $0.index }))
//            for book in books {
//                for tagName in book.tags {
//                    if let tag = tags.first { tag in tag.name == tagName } {
//                        
//                    }
//                }
//            }
//            try context.save()
        },
        didMigrate: { context in
//            let books = try context.fetch(FetchDescriptor<DataSchemaV2.Book>())
            let tags = try context.fetch(FetchDescriptor<DataSchemaV2.Tag>())
            print("did", tags.map({ $0.index }))
//            for book in books {
//                for tagName in book.tagNames {
//                    if let tag = tags.first(where: { tag in tag.name == tagName }) {
//                        book.tags.append(tag)
//                    }
//                }
//            }
//            try context.save()
        }
    )
    static var stages: [MigrationStage] {
//        [migrateV1toV2]
        [MigrationStage.lightweight(fromVersion: DataSchemaV1.self, toVersion: DataSchemaV2.self)]
    }
}
