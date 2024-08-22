//
//  ContentView.swift
//  Read
//
//  Created by wanruuu on 2/8/2024.
//

import SwiftUI
import SwiftData


struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var books: [Book]

    var body: some View {
        BookListView()
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Book.self)
        .modelContainer(for: Tag.self)
}
