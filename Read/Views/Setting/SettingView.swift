//
//  SettingView.swift
//  Read
//
//  Created by wanruuu on 8/9/2024.
//
import SwiftUI
import SwiftData

struct SettingView: View {
    @State private var isShowingExporter = false
    
    @Query private var books: [Book]
    
    var body: some View {
        List {
            Section {
                Button("导出", systemImage: "square.and.arrow.up") {
                    isShowingExporter = true
                }
                .fileExporter(isPresented: $isShowingExporter, document: TextFile(books: books), contentType: .plainText) { result in
                    switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            Section {
                NavigationLink {
                    TagListView()
                } label: {
                    Label("标签管理", systemImage: "bookmark")
                }
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

