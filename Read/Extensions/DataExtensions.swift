//
//  DataExtensions.swift
//  Read
//
//  Created by wanruuu on 2/11/2024.
//

import Foundation


extension Data {
    var stringEncoding: String.Encoding? {
        var nsString: NSString?
        guard case let rawValue = NSString.stringEncoding(for: self, encodingOptions: nil, convertedString: &nsString, usedLossyConversion: nil), rawValue != 0 else { return nil }
        return .init(rawValue: rawValue)
    }

    func extractBook() -> ([String], [[String]], Int) {
        guard let stringEncoding = self.stringEncoding else { return ([], [], 0) }
        let content = (String(data: self, encoding: stringEncoding) ?? "").replacing("　", with: "")
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
        return (titles, paragraphs, self.count)
    }
}
