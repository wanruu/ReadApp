//
//  BookTableView.swift
//  Read
//
//  Created by wanruuu on 16/8/2024.
//

import SwiftUI


// MARK: - 笔记
// 在SwiftUI中使用UIViewController改变父视图中的值，可以在VC中接受Binding<>?类型，例如Binding<String>?。
// 数据流：SwiftUI (@State or @Binding) -> UIViewControllerRepresentable (@Binding) -> UIViewController (Binding<>?)
//
// 1. 在UIViewControllerRepresentable中的makeUIViewController方法，将变量传递给子视图UIViewController；
//    在updateUIViewController方法中更新子视图的变量（需要吗，待研究。Binding储存的是值还是位置？），如果有需要就主动更新视图。
// 2. 在UIViewController中，viewDidLoad只会在makeUIViewController的时候执行一次，所以更新要在上级实现。（或者写个reload函数给上级调用）
// 3. 在UIViewController中，可以通过更改Binding<>?的wrappedValue的值达到目的。



struct BookTableView: UIViewControllerRepresentable {
    @Bindable var book: Book

    @Binding var isChangingChapter: Bool
    @Binding var readingStatus: ReadingStatus

    
    func makeUIViewController(context: Context) -> BookTableViewController {
        let tableViewController = BookTableViewController()
        tableViewController.book = BookForTable(book: book)
        return tableViewController
    }

    func updateUIViewController(_ uiViewController: BookTableViewController, context: Context) {
        if isChangingChapter {  // Only call scrollTo when need to change chapter
            DispatchQueue.global().async {
                let newIndexPath = IndexPath(row: book.lastParagraphIndex, section: book.lastChapterIndex)
                DispatchQueue.main.async {
                    uiViewController.tableView.scrollToRow(at: newIndexPath, at: .top, animated: true)
                }
                uiViewController.speechIndexPath = newIndexPath
                isChangingChapter = false
            }
        }
        uiViewController.handleStatusChange(readingStatus)
    }
}

