//
//  TextEditorView.swift
//  Read
//
//  Created by wanruuu on 20/8/2024.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var text: String
    @State var textEditorHeight : CGFloat = 20
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .foregroundColor(.clear)
                .padding(14)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                })
            TextEditor(text: $text)
                .frame(height: max(40, textEditorHeight))
                .cornerRadius(10.0).shadow(radius: 1.0)
                .focused($isFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if isFocused {
                            HStack {
                                Spacer()
                                Button {
                                    isFocused = false
                                } label: {
                                    Text("完成").bold()
                                }
                            }
                        }
                    }
                }
        }
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
