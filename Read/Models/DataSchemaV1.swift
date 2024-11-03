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
            let (titles, paragraphs, size) = data.extractBook()
            self.titles = titles
            self.paragraphs = paragraphs
            self.size = size
            if (self.lastChapterIndex > self.titles.count) {
                self.lastChapterIndex = self.titles.count - 1
            }
            if (self.lastParagraphIndex > self.paragraphs[self.lastChapterIndex].count) {
                self.lastParagraphIndex = self.paragraphs[self.lastChapterIndex].count - 1
            }
            print(self.titles.count, self.paragraphs.count, self.size)
        }
    }
}
