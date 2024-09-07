//
//  DataSchemaV1.swift
//  Read
//
//  Created by wanruuu on 7/9/2024.
//

import Foundation
import SwiftData


enum DataSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Tag.self, Book.self]
    }
    
    @Model
    class Tag {
        @Attribute(.unique) var index: Int
        var name: String
        var books: [Book] = []

        init(index: Int, name: String) {
            self.name = name
            self.index = index
        }
    }
    
    @Model
    class Book {
        @Attribute(.unique) var index: Int
        var name: String  // Book name
        var author: String = ""  // Author name
        var timestamp: Date  // Saved time
        var size: Int = 0  // File size in bytes
        
        var rating: Int = 0  // 0-5
        var summary: String = ""
        @Relationship(inverse: \Tag.books) var tags: [Tag] = []

        var titles: [String] = []
        var paragraphs: [[String]] = []
        var lastChapterIndex: Int = 0
        var lastParagraphIndex: Int = 0  // Last read paragraph index
        
        // TODO: deprecated
        var tagNames: [String] = []

        init(index: Int, filename: String, data: Data? = nil) {
            self.index = index
            self.name = filename.components(separatedBy: ".").first ?? filename
            self.timestamp = Date()
            
            if let data = data {
                inject(data)
            }
        }
        
        public func inject(_ data: Data) {
            (self.titles, self.paragraphs, self.size) = Book.extractContent(data)
        }
        
        private static func extractContent(_ data: Data) -> ([String], [[String]], Int) {
            let content = (String(data: data, encoding: .utf16) ?? "").replacing("　", with: "")
            let paras = content.components(separatedBy: .newlines).filter { str in str != "" }
            
            // Extract titles
            // TODO: allow user to decide title pattern
            let pattern = /^第[0-9一二三四五六七八九十零百千]+章.*/
            let titleItems = paras.enumerated().filter({ it in
                it.element.firstMatch(of: pattern) != nil
            })
            var titles = titleItems.map({ it in it.element })
            var paragraphs = [[String]]()
            
            // Split paras by title
            if titleItems.first?.offset != 0 {
                titles.insert("前言", at: 0)
                
                var lastTitleIndex = 0
                paragraphs = titleItems.map({ it in
                    let para = Array(paras[lastTitleIndex..<it.offset])
                    lastTitleIndex = it.offset
                    return para
                })
                paragraphs.append(Array(paras[lastTitleIndex...]))
            } else if titleItems.first?.offset == 0 {
                var lastTitleIndex = 0
                paragraphs = titleItems[1...].map({ it in
                    let para = Array(paras[lastTitleIndex..<it.offset])
                    lastTitleIndex = it.offset
                    return para
                })
                paragraphs.append(Array(paras[lastTitleIndex...]))
            }
            return (titles, paragraphs, data.count)
        }
    }
}
