//
//  TagListView.swift
//  Read
//
//  Created by wanruuu on 10/9/2024.
//

import SwiftUI
import SwiftData


struct TagListView: View {
    // Data
    @Query(sort: \Tag.index) private var tags: [Tag]
    
    // Edit/add tag
    @State private var isShowingAlert = false
    @State private var tagToEdit: Tag?
    @State private var text: String = ""
    
    // Delete
    @State private var isShowingConfirmation = false
    @State private var tagToDelete: Tag?

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            List {
                ForEach(tags) { tag in
                    NavigationLink {
                        BookListView(tagName: tag.name)
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("# " + tag.name)
                            Text("共 \(tag.books.count) 本书")
                                .foregroundStyle(Color.secondary)
                                .font(.footnote)
                        }
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash") {
                            isShowingConfirmation = true
                            tagToDelete = tag
                        }.tint(Color.red)
                        Button("Edit", systemImage: "square.and.pencil") {
                            isShowingAlert = true
                            tagToEdit = tag
                            text = tag.name
                        }
                    }
                }
                .onMove(perform: move)
            }
            NewTagSheet(text: $text, isShowing: $isShowingAlert, onSubmit: {
                Task {
                    if let tag = tagToEdit {
                        tag.name = text
                    } else {
                        let tag = Tag(index: (tags.last?.index ?? -1) + 1, name: text)
                        modelContext.insert(tag)
                    }
                }
            })
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("添加") {
                    isShowingAlert = true
                    tagToEdit = nil
                    text = ""
                }
            }
        }
        .confirmationDialog("", isPresented: $isShowingConfirmation, actions: {
            Button("删除", role: .destructive) {
                withAnimation {
                    if let tag = tagToDelete {
                        modelContext.delete(tag)
                    }
                }
            }
        }, message: {
            Text("确定删除标签“\(tagToDelete?.name ?? "")”？")
        })
        .navigationTitle("标签管理")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func move(from source: IndexSet, to destination: Int) {
//        tags.move(fromOffsets: source, toOffset: destination)
        // TODO
    }
    
    
    struct NewTagSheet: View {
        @State var title: String = "标签"
        @Binding var text: String
        @Binding var isShowing: Bool
        let onSubmit: (() -> Void)?
        
        @FocusState private var isFocused: Bool
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            ZStack(alignment: .bottom) {
                if isShowing {
                    Color.black
                        .opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    VStack(spacing: 20) {
                        HStack {
                            Button("取消") {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                            Spacer()
                            Text(title).bold()
                            Spacer()
                            Button("完成") {
                                withAnimation {
                                    isShowing = false
                                    onSubmit?()
                                }
                            }
                            .bold()
                        }
                        TextField("请输入标签", text: $text)
                            .focused($isFocused)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                withAnimation {
                                    isShowing = false
                                    onSubmit?()
                                }
                            }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .light ? Color.white : Color(red: 28/255, green: 28/255, blue: 30/255))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .onAppear {
                        isFocused = true
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(.easeInOut, value: isShowing)
        }
    }
}
