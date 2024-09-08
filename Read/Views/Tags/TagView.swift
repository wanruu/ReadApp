//
//  TagView.swift
//  Read
//
//  Created by wanruuu on 8/9/2024.
//

import SwiftUI

struct TagView: View {
    @State var text: String
    @Environment(\.colorScheme) private var colorSchema: ColorScheme

    var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .bold))
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .foregroundStyle(Color.secondary)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(Color(uiColor: colorSchema == .light ? .systemGray6 : .systemGray5))
            )
    }
}
