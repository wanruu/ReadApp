//
//  TagsPickerView.swift
//  Read
//
//  Created by wanruuu on 20/8/2024.
//

import SwiftUI
import SwiftData


struct TagsPickerView: View {
    @Binding var selections: Set<String>
    
    @State private var buttonIdx: Int?
    @Query(sort: [SortDescriptor(\Tag.name)]) private var tags: [Tag]
    @Environment(\.modelContext) private var modelContext

    private var selectionsString: String {
//        ListFormatter.localizedString(byJoining: selections.map { $0.description })
        selections.isEmpty ? "无" :
        tags.map({ $0.name }).filter({ selections.contains($0) }).joined(separator: ", ")
    }
    
    var body: some View {
        NavigationLink {
            List {
                Section {
                    // TODO: select all / deselect all / add tag button
                }
                ForEach(tags) { tag in
                    Button {
                        if selections.contains(tag.name) {
                            selections.remove(tag.name)
                        } else {
                            selections.insert(tag.name)
                        }
                    } label: {
                        HStack {
                            Text(tag.name).foregroundStyle(Color.primary)
                            Spacer()
                            if selections.contains(tag.name) {
                                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }
        } label: {
            Text(selectionsString)
        }
    }
}
