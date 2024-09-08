//
//  BookForTable.swift
//  Read
//
//  Created by wanruuu on 17/8/2024.
//


import Foundation


// MARK: - 笔记
// 直接将bindable传入UITableViewController会很卡，原因未知。
// 可能的原因：1. 不支持bindable；2. 赋值的过程阻碍了主线程。
// 解决方案：创建一个新的结构替代book


struct BookForTable {
    struct Chapter {
        var title: String
        var paragraphs: [String]
    }
    
    var chapters: [Chapter]
    var indexPath: IndexPath  // Only fetched once when table view is loaded to screen for the first time
    var updateIndexPath: ((IndexPath) -> Void)?
    
    init() {
        chapters = []
        indexPath = IndexPath(row: 0, section: 0)
    }
    init(book: Book) {
        chapters = zip(book.titles, book.paragraphs).map { title, paras in
            Chapter(title: title, paragraphs: paras)
        }
        indexPath = IndexPath(row: book.lastParagraphIndex, section: book.lastChapterIndex)
        updateIndexPath = { indexPath in
            book.lastChapterIndex = indexPath.section
            book.lastParagraphIndex = indexPath.row
        }
    }
}
