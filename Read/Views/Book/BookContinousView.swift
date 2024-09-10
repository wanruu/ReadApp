//
//  BookContinousView.swift
//  Read
//
//  Created by wanruuu on 10/8/2024.
//

import SwiftUI


struct ReadingStatus: Equatable {
    var isReading: Bool
    var isPaused: Bool

    static let on = ReadingStatus(isReading: true, isPaused: false)
    static let off = ReadingStatus(isReading: false, isPaused: false)
    static let paused = ReadingStatus(isReading: true, isPaused: true)
}

struct BookContinousView: View {
    @Bindable var book: Book
    
    @State private var isShowingToolbar = false
    @State private var activeSheet: ActiveSheet?
    @State private var isChangingChapter = false
    
    @State private var readingStatus: ReadingStatus = .off
    @State private var readingSecondsLeft: Int = 0

    var body: some View {
        if book.paragraphs.isEmpty {
            ZStack {
                Color.readingBackground.ignoresSafeArea()
                Text("暂无内容")
                    .font(.title)
                    .foregroundStyle(Color.readingForeground)
            }
        } else {
            ZStack {
                BookTableView(book: book, isChangingChapter: $isChangingChapter, readingStatus: $readingStatus)
                SpeakButtonView(readingStatus: $readingStatus, readingSecondsLeft: $readingSecondsLeft)
            }
                .onTapGesture {
                    withAnimation {
                        if !readingStatus.isReading {
                            isShowingToolbar.toggle()
                        }
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0, content: {
                    isShowingToolbar ? nil : HStack { Spacer() }.background(Color.readingBackground)
                })
                .safeAreaInset(edge: .bottom, spacing: 0, content: {
                    isShowingToolbar ? nil : HStack {
                        Text(book.titles[book.lastChapterIndex])
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Text("")
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .background(Color.readingBackground)
                })
                .navigationTitle(book.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(isShowingToolbar ? .visible : .hidden, for: .navigationBar)
                .toolbar(isShowingToolbar ? .visible : .hidden, for: .bottomBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Info", systemImage: "exclamationmark.circle", action: { activeSheet = .info })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("设置", systemImage: "gear", action: { activeSheet = .setting })
                    }
                    ToolbarItem(placement: .bottomBar, content: bottomBarView)
                }
                .sheet(item: $activeSheet) { item in
                    NavigationStack {
                        switch item {
                        case .catalog:
                            BookCatalogView(book: book, isChangingChapter: $isChangingChapter)
                                .navigationTitle(Text("目录"))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .topBarTrailing) {
                                        Button("关闭", action: { activeSheet = nil })
                                    }
                                }
                        case .setting:
                            BookSettingView()
                                .navigationTitle(Text("设置"))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .topBarTrailing) {
                                        Button("关闭", action: { activeSheet = nil })
                                    }
                                }
                        case .info:
                            BookInfoView(book: book)
                            
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
        }
    }
    
    private enum ActiveSheet: Identifiable {
        case catalog
        case setting
        case info
        var id: Int {
            hashValue
        }
    }
    
    // MARK: - components
    private func bottomBarView() -> some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                activeSheet = .catalog
            } label: {
                Image(systemName: "list.bullet").imageScale(.large)
            }
            Spacer()
            Divider()
            Spacer()
            Button {
                if book.lastChapterIndex != 0 {
                    isChangingChapter = true
                    book.lastChapterIndex -= 1
                    book.lastParagraphIndex = 0
                }
            } label: {
                Text("上一章")
            }
            .disabled(book.lastChapterIndex == 0)
            .foregroundStyle(book.lastChapterIndex == 0 ? Color.gray : Color.primary)
            .buttonStyle(.bordered)
            Spacer()
            Button {
                if book.lastChapterIndex != book.paragraphs.count - 1 {
                    isChangingChapter = true
                    book.lastChapterIndex += 1
                    book.lastParagraphIndex = 0
                }
            } label: {
                Text("下一章")
            }
            .disabled(book.lastChapterIndex == book.paragraphs.count - 1)
            .foregroundStyle(book.lastChapterIndex == book.paragraphs.count - 1 ? Color.gray : Color.primary)
            .buttonStyle(.bordered)
            Spacer()
            Divider()
            Spacer()
            Button {
                withAnimation {
                    readingStatus.isReading = true
                    isShowingToolbar = false
                }
            } label: {
                Image(systemName: "play.circle").imageScale(.large)
            }
        }
    }
}
