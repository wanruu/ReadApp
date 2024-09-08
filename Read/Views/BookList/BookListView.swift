//
//  BookListView.swift
//  Read
//
//  Created by wanruuu on 2/8/2024.
//

import SwiftUI
import SwiftData


struct _BookListItemView: View {
    @State var book: Book
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.name)
            HStack(spacing: 2) {
                Text(book.author.isEmpty ? "?" : book.author)
                Text("·")
                Text(book.size.fileSizeDescription)
            }
            .font(.footnote)
            .foregroundStyle(Color.secondary)
            
            book.tags.isEmpty ? nil :
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
                            _BookListItemView(book: book)
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
            .alert("删除书本《\(bookToDelete?.name ?? "")》？", isPresented: $isShowingDeleteConfirm) {
                Button("删除", role: .destructive) {
                    if let b = bookToDelete {
                        deleteBook(b)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    BookListMenuView(options: $options)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Import", systemImage: "square.and.arrow.down") {
                        isShowingBookSelection = true
                    }
                    .fileImporter(isPresented: $isShowingBookSelection, allowedContentTypes: [.plainText], onCompletion: addBook)
                    Spacer()
                    Text("共 \(books.count) 本书").font(.footnote)
                    Spacer()
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "gear")
                    }
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

//#Preview {
//    BookListView()
//        .modelContainer(for: Book.self, inMemory: true)
//}
