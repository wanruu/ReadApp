//
//  BookCatalogView.swift
//  Read
//
//  Created by wanruuu on 8/8/2024.
//

import SwiftUI

struct BookCatalogView: View {
    @Bindable var book: Book
    @Binding var isChangingChapter: Bool

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollViewReader { reader in
            List(Array(book.titles.enumerated()), id: \.self.offset) { tuple in
                Button {
                    dismiss()
                    isChangingChapter = true
                    book.lastChapterIndex = tuple.offset
                    book.lastParagraphIndex = 0
                } label: {
                    HStack {
                        Text(tuple.element)
                        Spacer()
                        book.lastChapterIndex == tuple.offset ? Image(systemName: "checkmark") : nil
                    }
                }
                .id(tuple.offset)
            }
            .onAppear {
                reader.scrollTo(book.lastChapterIndex, anchor: .center)
            }
        }
    }
}
