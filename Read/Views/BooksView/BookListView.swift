//
//  BookListView.swift
//  Read
//
//  Created by wanruuu on 2/8/2024.
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


struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.timestamp, order: .reverse) private var books: [Book]
    
    @State private var searchText: String = ""
    
    @State private var isShowingBookSelection = false
    
    @State private var bookToEdit: Book?
    @State private var bookToDelete: Book?
    @State private var isShowingDeleteConfirm = false
    
    @State private var options: BookListOptions = .init()
    
    var body: some View {
        NavigationSplitView {
            let bookGroups = options.handle(books)
            let groupKeys = bookGroups.keys.sorted(by: { $0 < $1 })
            
            List(groupKeys, id: \.self) { groupKey in
                Section(groupKey) {
                    ForEach(bookGroups[groupKey] ?? []) { book in
                        NavigationLink {
                            BookContinousView(book: book)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(book.name)
                                book.tags.isEmpty ? nil :
                                TagsContainer {
                                    ForEach(book.tags) { tag in
                                        Text(tag.name)
                                            .font(.footnote)
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 4)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 1))
                                            }
                                    }
                                    .foregroundStyle(Color.secondary)
                                }
                                HStack(spacing: 3) {
                                    Text(book.author.isEmpty ? "?" : book.author)
                                    Text("·")
                                    Text(book.size.fileSizeDescription)
                                    Text("·")
                                    Text(book.rating == 0 ? "未评分" : "\(book.rating)分")
                                    Spacer()
                                    book.summary.isEmpty ? nil :
                                        Image(systemName: "message.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                }
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                            }
                        }
                        .swipeActions {
                            Button("Delete", systemImage: "trash.fill", role: .destructive) {
                                bookToDelete = book
                                isShowingDeleteConfirm = true
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Info", systemImage: "info.circle") { bookToEdit = book }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .sheet(item: $bookToEdit, content: { book in
                NavigationSplitView {
                    BookInfoView(book: book)
                } detail: {
                    Text("Book detail")
                }
            })
            .alert("删除书本《\(bookToDelete?.name ?? "")》？", isPresented: $isShowingDeleteConfirm, actions: {
                Button("删除", role: .destructive) {
                    if let b = bookToDelete {
                        deleteBook(b)
                    }
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    BookListMenuView(options: $options)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Text("共 \(books.count) 本书").font(.footnote)
                    Spacer()
                    Button("Import", systemImage: "square.and.arrow.down", action: { isShowingBookSelection = true })
                        .fileImporter(isPresented: $isShowingBookSelection, allowedContentTypes: [.plainText], onCompletion: addBook)
                }
            }
            .navigationTitle("书柜")
            .onAppear {
                NotificationCenter.default.addObserver(forName: .didReceiveSharedData, object: nil, queue: .main) { notification in
                    if let url = notification.userInfo?["url"] as? URL {
                        addBook(fileURL: url)
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: .didReceiveSharedData, object: nil)
            }
        } detail: {
            Text("Book list")
        }
    }

    private func deleteBook(_ book: Book) {
        withAnimation {
            modelContext.delete(book)
            try? modelContext.save()
        }
    }
    
    private func addBook(result: Result<URL, Error>) {
        do {
            addBook(fileURL: try result.get())
        } catch {
            print ("Error occurred when reading \(error.localizedDescription)")
        }
    }
    
    private func addBook(fileURL: URL) {
        do {
            if fileURL.startAccessingSecurityScopedResource() {
                let docData  = try Data(contentsOf: fileURL)
                withAnimation {
                    let newBook = Book(index: books.count, filename: fileURL.lastPathComponent)
                    modelContext.insert(newBook)
                    DispatchQueue.global().async {
                        newBook.inject(docData)
                        try? modelContext.save()
                    }
                }
            }
        } catch {
            print ("Error occurred when reading \(error.localizedDescription)")
        }
    }
}

#Preview {
    BookListView()
        .modelContainer(for: Book.self, inMemory: true)
}
