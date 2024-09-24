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
        case author = "作者"
        case title = "书名"
        case rating = "评分"
        case summary = "评论字数"
        var id: String { self.rawValue }
        init(forKey: String = "bookSortOption") {
            if let value = UserDefaults.standard.string(forKey: forKey), let option = SortOption(rawValue: value) {
                self = option
            } else {
                self = .createDate
            }
        }
        func save(forKey: String = "bookSortOption") {
            UserDefaults.standard.setValue(self.rawValue, forKey: forKey)
        }
    }
    
    enum Order: String,  CaseIterable, Identifiable {
        case asc = "升序"
        case desc = "降序"
        var id: String { self.rawValue }
        init(forKey: String) {
            if let value = UserDefaults.standard.string(forKey: forKey), let order = Order(rawValue: value) {
                self = order
            } else {
                self = .asc
            }
        }
        func save(forKey: String) {
            UserDefaults.standard.setValue(self.rawValue, forKey: forKey)
        }
    }

    enum GroupOption: String, CaseIterable, Identifiable {
        case none = "无"
        case author = "作者"
        case rating = "评分"
        case summary = "是否评论"
        var id: String { self.rawValue }
        init(forKey: String = "bookGroupOption") {
            if let value = UserDefaults.standard.string(forKey: forKey), let option = GroupOption(rawValue: value) {
                self = option
            } else {
                self = .none
            }
        }
        func save(forKey: String = "bookGroupOption") {
            UserDefaults.standard.setValue(self.rawValue, forKey: forKey)
        }
    }
        
    var sortOption: SortOption = .init()
    var sortOrder: Order = .init(forKey: "bookSortOrder")
    var groupOption: GroupOption = .init()
    var groupOrder: Order = .init(forKey: "bookGroupOrder")


    func save() {
        self.sortOption.save()
        self.groupOption.save()
        self.sortOrder.save(forKey: "bookSortOrder")
        self.groupOrder.save(forKey: "bookGroupOrder")
    }
    
    func handle(_ books: [Book]) -> ([String], [String: [Book]]) {
        var bookGroups = switch groupOption {
        case .none:
            ["": books]
        case .author:
            Dictionary(grouping: books) { book in book.author }
        case .rating:
            Dictionary(grouping: books) { book in book.rating == 0 ? "未评分" : "\(book.rating)分" }
        case .summary:
            Dictionary(grouping: books) { book in book.summary.isEmpty ? "未评论" : "已评论" }
        }
        let keys = bookGroups.keys.sorted { k1, k2 in
            switch groupOrder {
            case .asc:
                k1 < k2
            case .desc:
                k2 < k1
            }
        }
        for key in keys {
            bookGroups[key]?.sort(by: { b1, b2 in
                switch sortOption {
                case .createDate:
                    b1.timestamp < b2.timestamp
                case .author:
                    b1.author < b2.author
                case .title:
                    b1.name < b2.name
                case .rating:
                    b1.rating < b2.rating
                case .summary:
                    b1.summary.count < b2.summary.count
                }
            })
            if sortOrder == .desc {
                bookGroups[key]?.reverse()
            }
        }
        return (keys, bookGroups)
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
                    options.groupOption == .none ? nil :
                    Picker("Options", selection: $options.groupOrder) {
                        ForEach(BookListOptions.Order.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("分组方式", systemImage: "rectangle.3.group")
                    Text(options.groupOption.rawValue).font(.footnote).foregroundStyle(.secondary)
                }
                Menu {
                    Picker("Options", selection: $options.sortOption) {
                        ForEach(BookListOptions.SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    Picker("Options", selection: $options.sortOrder) {
                        ForEach(BookListOptions.Order.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("组内排序方式", systemImage: "arrow.up.arrow.down")
                    Text(options.sortOption.rawValue).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
        .onChange(of: options) { _, newValue in
            newValue.save()
        }
    }
}
