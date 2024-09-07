//
//  TextFile.swift
//  Read
//
//  Created by wanruuu on 8/9/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct TextFile: FileDocument {
    static var readableContentTypes = [UTType.plainText]
    
    var text = ""
    
    init(books: [Book]) {
        text = books.map { book in
            let tagsStr = book.tags.map({ $0.name }).joined(separator: ",")
            return [book.name, book.author, tagsStr, "\(book.rating)", book.summary].joined(separator: "\n")
        }.joined(separator: "\n--------------------\n")
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
