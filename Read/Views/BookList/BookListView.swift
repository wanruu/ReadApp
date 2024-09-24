//
//  BookListView.swift
//  Read
//
//  Created by wanruuu on 2/8/2024.
//

import SwiftUI
import SwiftData


struct BookListView: View {
    // Data
    @Query var books: [Book]
    
    init(filter: (() -> Predicate<Book>)? = nil) {
        _books = Query(filter: filter?())
    }
    
    init(tagName: String) {
        _books = Query(filter: #Predicate<Book>{ book in
            book.tags.contains { _tag in
                _tag.name == tagName
            }
        })
    }

    // Edit or delete book
    @Environment(\.modelContext) private var modelContext
    @State private var bookToEdit: Book?
    @State private var bookToDelete: Book?
    @State private var bookToImport: Book?
    @State private var isShowingDeleteConfirm = false
    @State private var isShowingImporter = false
    
    // Menu
    @State private var options: BookListOptions = .init()

    var body: some View {
        List {
            if options.groupOption == .none {
                ForEach(books) { book in
                    BookItemView(book: book)
                }
            } else {
                let bookGroups = options.handle(books)
                let groupKeys = bookGroups.keys.sorted(by: { $0 < $1 })
                ForEach(groupKeys, id: \.self) { groupKey in
                    Section(groupKey) {
                        ForEach(bookGroups[groupKey] ?? []) { book in
                            BookItemView(book: book)
                        }
                    }
                }
            }
        }
        .sheet(item: $bookToEdit, content: { book in
            NavigationStack {
                BookInfoView(book: book)
            }
        })
        .confirmationDialog("", isPresented: $isShowingDeleteConfirm, actions: {
            Button("删除", role: .destructive) { deleteBook(bookToDelete) }
        }, message: {
            Text("确定删除《\(bookToDelete?.name ?? "")》？")
        })
        .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.plainText], onCompletion: updateBook)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                BookListMenuView(options: $options)
            }
        }

//        .onAppear {
//            NotificationCenter.default.addObserver(forName: .didReceiveSharedData, object: nil, queue: .main) { notification in
//                if let url = notification.userInfo?["url"] as? URL {
//                    addBook(fileURL: url)
//                }
//            }
//        }
//        .onDisappear {
//            NotificationCenter.default.removeObserver(self, name: .didReceiveSharedData, object: nil)
//        }
    }

    private func deleteBook(_ book: Book?) {
        withAnimation {
            if let book = book {
                modelContext.delete(book)
            }
        }
    }
    
    private func updateBook(result: Result<URL, Error>) {
        do {
            let fileURL = try result.get()
            if let book = bookToImport, fileURL.startAccessingSecurityScopedResource() {
                let docData  = try Data(contentsOf: fileURL)
                book.inject(docData)
            }
        } catch {
            print ("Error occurred when reading \(error.localizedDescription)")
        }
    }
    
    private func BookItemView(book: Book) -> some View {
        NavigationLink {
            BookView(book: book)
        } label: {
            VStack(alignment: .leading) {
                Text(book.name)
                HStack(spacing: 2) {
                    Text(book.author.isEmpty ? "?" : book.author)
                    Text("·")
                    Text(book.size.fileSizeDescription)
                }
                .font(.footnote)
                .foregroundStyle(Color.secondary)
                if !book.tags.isEmpty {
                    TagsContainer {
                        ForEach(book.tags) { tag in
                            TagView(text: "#" + tag.name)
                        }
                        book.rating == 0 ? nil :
                        TagView(text: "\(book.rating)分")
                        book.summary.isEmpty ? nil :
                        TagView(text: "\(book.summary.count)字评论")
                    }
                }
            }
        }
        .swipeActions {
            Button("Delete", systemImage: "trash.fill") {
                bookToDelete = book
                isShowingDeleteConfirm = true
            }
            .tint(.red)
            Button("Info", systemImage: "info.circle") {
                bookToEdit = book
            }
        }
        .swipeActions(edge: .leading) {
            Button("Import", systemImage: "square.and.arrow.down") {
                bookToImport = book
                isShowingImporter = true
            }
        }
    }
}
