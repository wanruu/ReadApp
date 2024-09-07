//
//  TagsContainer.swift
//  Read
//
//  Created by wanruuu on 18/8/2024.
//

import SwiftUI


struct TagsContainer<Content: View>: View {
    @State var horizontalSpacing: CGFloat = 8
    @State var verticalSpacing: CGFloat = 5
    @ViewBuilder let content: Content

    @State private var yRange: CGPoint = .zero

    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        GeometryReader { geo in
            Extract(content) { views in
                ZStack(alignment: .topLeading) {
                    ForEach(views) { view in
                        view
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > geo.size.width) {
                                    width = 0
                                    height -= d.height + verticalSpacing
                                }
                                let result = width
                                if view.id == views.last?.id {
                                    width = 0
                                } else {
                                    width -= d.width + horizontalSpacing
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: { d in
                                let result = height
                                if view.id == views.last?.id {
                                    height = 0
                                }
                                return result
                            })
                            .background(GeometryReader { geometry in
                                let rect = geometry.frame(in: .named("tags"))
                                let point = CGPoint(x: rect.minY, y: rect.maxY)
                                Color.clear.preference(key: TagPreferenceKey.self, value: point)
                            })
                    }
                }
                .coordinateSpace(name: "tags")
            }
        }
        .onPreferenceChange(TagPreferenceKey.self) { val in
            if abs((yRange.y - yRange.x) - (val.y - val.x)) > 1 {
                yRange = val
            }
        }
        .frame(height: yRange.y - yRange.x)
    }
}


struct TagPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero  // x: minY, y: maxY
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        let v = nextValue()
        value = CGPoint(x: min(value.x, v.x), y: max(value.y, v.y))
    }
}


protocol Extractable: View {
    associatedtype Content: View
    associatedtype ViewsContent: View

    var content: () -> Content { get }
    var views: (Views) -> ViewsContent { get }

    init(_ content: Content, @ViewBuilder views: @escaping (Views) -> ViewsContent)
    init(@ViewBuilder _ content: @escaping () -> Content, @ViewBuilder views: @escaping (Views) -> ViewsContent)
}


public typealias Views = _VariadicView.Children


public struct Extract<Content: View, ViewsContent: View>: Extractable {
    let content: () -> Content
    let views: (Views) -> ViewsContent

    public init(_ content: Content, @ViewBuilder views: @escaping (Views) -> ViewsContent) {
        self.content = { content }
        self.views = views
    }

    public init(@ViewBuilder _ content: @escaping () -> Content, @ViewBuilder views: @escaping (Views) -> ViewsContent) {
        self.content = content
        self.views = views
    }

    public var body: some View {
        _VariadicView.Tree(
            UnaryViewRoot(views: views),
            content: content
        )
    }
}


fileprivate struct UnaryViewRoot<Content: View>: _VariadicView_UnaryViewRoot {
    let views: (Views) -> Content

    func body(children: Views) -> some View {
        views(children)
    }
}
