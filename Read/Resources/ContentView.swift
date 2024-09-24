//
//  ContentView.swift
//  Read
//
//  Created by wanruuu on 2/8/2024.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    // Import book
    @State private var isShowingImporter = false
    @Environment(\.modelContext) private var modelContext

    // Title
    @Query private var books: [Book]
    
    // Search for book
    @State private var searchText: String = ""
    private func getPredicate() -> Predicate<Book> {
        #Predicate<Book>{ book in
            searchText.isEmpty ||
            book.name.contains(searchText) ||
            book.author.contains(searchText) ||
            book.tags.contains(where: { tag in tag.name.contains(searchText) })
        }
    }

    var body: some View {
        NavigationStack {
            BookListView(filter: getPredicate)
                .scrollDismissesKeyboard(.immediately)
                .searchable(text: $searchText)
                .navigationTitle("书柜")
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Import", systemImage: "square.and.arrow.down") {
                            isShowingImporter = true
                        }
                        .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.plainText], onCompletion: addBook)
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
                    }
                }
            }
        } catch {
            print ("Error occurred when reading \(error.localizedDescription)")
        }
    }
}


//#Preview {
//    ContentView()
//        .modelContainer(for: Book.self)
//        .modelContainer(for: Tag.self)
//}
