//
//  Book.swift
//  Read
//
//  Created by wanruuu on 2/8/2024.
//

import Foundation
import SwiftData

@Model
final class Book {
    var index: Int
    var name: String  // Book name
    var author: String  // Author name
    var timestamp: Date  // Saved time
    var size: Int  // File size in bytes
    
    var rating: Int  // 0-5
    var summary: String
    var tags: [String]

    var titles: [String]
    var paragraphs: [[String]]
    var lastChapterIndex: Int
    var lastParagraphIndex: Int  // Last read paragraph index
    
    init(index: Int, filename: String, data: Data? = nil) {
        self.index = index
        self.name = filename.components(separatedBy: ".").first ?? filename
        self.author = ""
        self.timestamp = Date()
        self.size = 0
        
        self.rating = 0
        self.summary = ""
        self.tags = []

        self.titles = []
        self.paragraphs = []
        self.lastChapterIndex = 0
        self.lastParagraphIndex = 0
        
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
