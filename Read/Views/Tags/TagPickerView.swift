//
//  TagPickerView.swift
//  Read
//
//  Created by wanruuu on 20/8/2024.
//

import SwiftUI
import SwiftData


struct TagPickerView: View {
    @Binding var selections: [Tag]
    
    @Query(sort: \Tag.index) private var tags: [Tag]
    @State private var isShowingTagList = false

    var body: some View {
        Button {
            isShowingTagList = true
        } label: {
            Text(selections.isEmpty ? "无" : selections.map({ $0.name }).joined(separator: ", "))
                .foregroundStyle(Color.primary)
        }
        .navigationDestination(isPresented: $isShowingTagList) {
            List {
                ForEach(tags) { tag in
                    Label {
                        Text(tag.name)
                    } icon: {
                        Button {
                            if let idx = selections.firstIndex(of: tag) {
                                selections.remove(at: idx)
                            } else {
                                selections.append(tag)
                                selections.sort(by: { $0.index < $1.index })
                            }
                        } label: {
                            selections.contains(tag) ?
                            Image(systemName: "circle.inset.filled").foregroundStyle(Color.accentColor):
                            Image(systemName: "circle").foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        isShowingTagList = false
                    }.bold()
                }
            }
        }
    }
}
