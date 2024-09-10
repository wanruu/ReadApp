//
//  TagListView.swift
//  Read
//
//  Created by wanruuu on 10/9/2024.
//

import SwiftUI
import SwiftData


struct TagListView: View {
    @Query(sort: \Tag.index) private var tags: [Tag]

    var body: some View {
        List {
            ForEach(tags) { tag in
                NavigationLink {
                    List {
                        ForEach(tag.books) { book in
                            BookListView.BookItemView(book: book)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    VStack(alignment: .leading) {
                        Text("# " + tag.name)
                        Text("共 \(tag.books.count) 本书")
                            .foregroundStyle(Color.secondary)
                            .font(.footnote)
                    }
                }
            }
        }
        .navigationTitle("标签管理")
        .navigationBarTitleDisplayMode(.inline)
    }
}



//struct _TagListView: View {
//    @Query(sort: \Tag.index) private var tags: [Tag]
//    @Environment(\.modelContext) private var modelContext
//
//    @State private var tagsToEdit: [_Tag] = []
//    @FocusState private var focusedField: Int?
//    @State private var editMode: EditMode = .inactive
//
//    var body: some View {
//        List {
//            if editMode.isEditing {
//                ForEach($tagsToEdit) { tag in
//                    let isLast = tag.id == tagsToEdit.last?.id
//                    Label {
//                        TextField("", text: tag.name)
//                            .focused($focusedField, equals: tag.id)
//                            .submitLabel(.next)
//                            .onSubmit {
//                                if isLast {
//                                    if !tag.name.wrappedValue.isEmpty {
//                                        tagsToEdit.append(_Tag(id: tag.id + 1, name: ""))
//                                        focusedField = tagsToEdit.last?.id
//                                    }
//                                } else {
//                                    if let idx = tagsToEdit.firstIndex(where: { $0.id == tag.id }) {
//                                        focusedField = tagsToEdit[idx + 1].id
//                                    }
//                                }
//                            }
//                    } icon: {
//                        Image(systemName: isLast ? "circle.dotted" : "circle")
//                            .foregroundStyle(Color.secondary)
//                    }
//                }
//            } else {
//                ForEach(tags) { tag in
//                    Label {
//                        Text(tag.name)
//                    } icon: {
//                        Button {
//                            if let idx = selections.firstIndex(of: tag) {
//                                selections.remove(at: idx)
//                            } else {
//                                selections.append(tag)
//                                selections.sort(by: { $0.index < $1.index })
//                            }
//                        } label: {
//                            selections.contains(tag) ?
//                            Image(systemName: "circle.inset.filled").foregroundStyle(Color.accentColor):
//                            Image(systemName: "circle").foregroundStyle(Color.secondary)
//                        }
//                    }
//                }
//                .onDelete { indexSet in
//                    withAnimation {
//                        for index in indexSet {
//                            modelContext.delete(tags[index])
//                            selections.removeAll(where: { $0 == tags[index] })
//                        }
//                        do {
//                            try modelContext.save()
//                        } catch {
//                            fatalError("Error")
//                        }
//                    }
//                }
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                if editMode.isEditing {
//                    HStack {
//                        Button("取消") {
//                            editMode = .inactive
//                        }
//                        Button("保存") {
//                            saveTags()
//                            editMode = .inactive
//                        }.bold()
//                    }
//                } else {
//                    Button("编辑") {
//                        tagsToEdit = tags.map({ _Tag(id: $0.index, name: $0.name) })
//                        tagsToEdit.append(_Tag(id: (tagsToEdit.last?.id ?? -1) + 1, name: ""))
//                        editMode = .active
//                    }
//                }
//            }
//        }
//    }
//
//    private struct _Tag: Identifiable {
//        var id: Int  // also index
//        var name: String
//    }
//    
//    private func saveTags() {
//        withAnimation {
//            let tagsToSave = Array(tagsToEdit[0..<tagsToEdit.count-1])
//            for tag in tags {
//                if let tagToSave = tagsToSave.first(where: { $0.id == tag.index }) {
//                    tag.index = tagToSave.id
//                    tag.name = tagToSave.name
//                } else {
//                    modelContext.delete(tag)
//                }
//            }
//            
//            let newTags = tagsToSave.filter({ !tags.map({ $0.index }).contains($0.id) })
//            for newTag in newTags {
//                let t = Tag(index: newTag.id, name: newTag.name)
//                modelContext.insert(t)
//            }
//            try? modelContext.save()
//        }
//    }
//}
