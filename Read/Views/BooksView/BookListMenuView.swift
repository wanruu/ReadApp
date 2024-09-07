//
//  BookListMenuView.swift
//  Read
//
//  Created by wanruuu on 8/9/2024.
//

import SwiftUI
import SwiftData

struct BookListOptions: Equatable {
    enum SortOption: String, CaseIterable, Identifiable {
        case createDate = "创建日期"
        case viewDate = "浏览日期"
        case author = "作者"
        case title = "书名"
        var id: String { self.rawValue }
    }

    enum GroupOption: String, CaseIterable, Identifiable {
        case none = "无"
        case author = "作者"
        case rating = "评分"
        case summary = "是否评论"
        var id: String { self.rawValue }
    }
    
    var sortOption: SortOption
    var groupOption: GroupOption
    
    init() {
        if let s = UserDefaults.standard.string(forKey: "bookSortOption"), let o = SortOption(rawValue: s) {
            sortOption = o
        } else {
            sortOption = .createDate
        }
        if let g = UserDefaults.standard.string(forKey: "bookGroupOption"), let o = GroupOption(rawValue: g) {
            groupOption = o
        } else {
            groupOption = .none
        }
    }
    
    public func save() {
        UserDefaults.standard.setValue(self.sortOption.rawValue, forKey: "bookSortOption")
        UserDefaults.standard.setValue(self.groupOption.rawValue, forKey: "bookGroupOption")
    }
    
    public func handle(_ books: [Book]) -> [String: [Book]] {
//        let sortedBooks = books.sorted { b1, b2 in
//            switch sortOption {
//            case .createDate:
//                b1.timestamp < b2.timestamp
//            case .viewDate:
//                b1.timestamp < b2.timestamp
//            case .author:
//                b1.author < b2.author
//            case .title:
//                b1.name < b2.name
//            }
//        }
        if groupOption == .rating {
            return Dictionary(grouping: books) { book in book.rating == 0 ? "未评分" : "\(book.rating)分" }
        } else if groupOption == .author {
            return Dictionary(grouping: books) { book in book.author }
        } else if groupOption == .summary {
            return Dictionary(grouping: books) { book in book.summary.isEmpty ? "未评论" : "已评论" }
        }
        return ["": books]
    }
}


struct BookListMenuView: View {
    @Binding var options: BookListOptions

    var body: some View {
        Menu("Options", systemImage: "ellipsis.circle") {
            Section {
                Menu {
                    Picker("Options", selection: $options.groupOption) {
                        ForEach(BookListOptions.GroupOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("分组方式", systemImage: "rectangle.3.group")
                    Text(options.groupOption.rawValue).font(.footnote).foregroundStyle(.secondary)
                }
//                Menu {
//                    Picker("Options", selection: $options.sortOption) {
//                        ForEach(BookListOptions.SortOption.allCases) { option in
//                            Text(option.rawValue).tag(option)
//                        }
//                    }
//                } label: {
//                    Label("排序方式", systemImage: "arrow.up.arrow.down")
//                    Text(options.sortOption.rawValue).font(.footnote).foregroundStyle(.secondary)
//                }
            }
        }
        .onChange(of: options) { _, newValue in
            newValue.save()
        }
    }
}
