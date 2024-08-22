//
//  BookInfoView.swift
//  Read
//
//  Created by wanruuu on 14/8/2024.
//

import SwiftUI
import SwiftData


struct BookInfoView: View {
    @Bindable var book: Book
    
    @State private var info = BookForInfo()
    @State private var isShowingUnsaveConfirm = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Tag.name)]) private var tags: [Tag]

    var body: some View {
        let hasChange = !info.isEqual(to: book)
        Form {
            TextField("书名", text: $info.name)
                .padding(.vertical, 5)
                .font(.title2).bold()
                .multilineTextAlignment(.center)
            Section("作者") {
                TextField("", text: $info.author)
            }
            Section("评价") {
                ratingView()
                TextEditor(text: $info.summary)
                    .frame(minHeight: 200)
            }
            Section {
                TagsPickerView(selections: $info.tags)
            } header: {
                Text("标签")
            } footer: {
                Text("共\(info.tags.count)个标签")
            }
        }
        .navigationTitle(Text("书本信息"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消", role: .cancel) {
                    if hasChange {
                        isShowingUnsaveConfirm.toggle()
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("完成") {
                    if hasChange {
                        info.save(to: book)
                    }
                    dismiss()
                }.bold().disabled(info.name.isEmpty)
            }
        }
        .confirmationDialog("", isPresented: $isShowingUnsaveConfirm) {
            Button("放弃更改", role: .destructive) { dismiss() }
        }
        .onAppear {
            if info.name.isEmpty {
                info = BookForInfo(book: book)
            }
        }
        .interactiveDismissDisabled(hasChange)
    }
    
    // Components
    func ratingView() -> some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { val in
                Button {
                    info.rating = info.rating == val ? 0 : val
                } label: {
                    Image(systemName: val <= info.rating ? "star.fill" : "star")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


struct BookForInfo {
    var name: String
    var author: String
    var rating: Int
    var summary: String
    var tags: Set<String>
    
    init(book: Book? = nil) {
        name = book?.name ?? ""
        author = book?.author ?? ""
        rating = book?.rating ?? 0
        summary = book?.summary ?? ""
        tags = Set(book?.tags ?? [])
    }
    func save(to book: Book) {
        book.name = name
        book.author = author
        book.rating = rating
        book.summary = summary
        book.tags = Array(tags)
    }
    func isEqual(to book: Book) -> Bool {
        return book.name == name &&
        book.author == author &&
        book.rating == rating &&
        book.summary == summary &&
        Set(book.tags) == tags
    }
}
