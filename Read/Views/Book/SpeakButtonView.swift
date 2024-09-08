//
//  ReadingButtonView.swift
//  Read
//
//  Created by wanruuu on 15/8/2024.
//

import SwiftUI


struct SpeakButtonView: View {
    @Binding var readingStatus: ReadingStatus
    @Binding var readingSecondsLeft: Int
    
    // Size
    let buttonSize: CGFloat = 30
    let timerWidth: CGFloat = 60
    let spacing: CGFloat = 10
    let width: CGFloat = 30 * 2 + 60 + 20 + 40
    let height: CGFloat = 50
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var status: Status = .inactive
    @State private var dragOffset: CGSize = .zero
    @State private var position: CGSize = .zero
    
    private enum Status {
        case active, inactive
    }
    private func getSecondsLeftString() -> String {
        if readingSecondsLeft == 0 {
            return "计时"
        }
        let h = readingSecondsLeft / 3600
        let m = (readingSecondsLeft - h * 3600) / 60
        let s = readingSecondsLeft - h * 3600 - m * 60
        let f = "%02d"
        return "\(h):\(String(format: f, m)):\(String(format: f, s))"
    }
    
    var body: some View {
        readingStatus.isReading ? VStack {
            Spacer()
            GeometryReader { proxy in
                HStack(spacing: spacing) {
                    Button {
                        readingStatus = (readingStatus == .paused ? .on : .paused)
                    } label: {
                        Image(systemName: readingStatus == .paused ? "play.circle" : "pause.circle")
                            .resizable()
                            .frame(width: buttonSize, height: buttonSize)
                    }
                    Button {
                        readingStatus = .off
                    } label: {
                        Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: buttonSize, height: buttonSize)
                    }
                    Menu {
                        ForEach([15, 30, 45, 60, 90], id: \.self) { minutes in
                            Button {
                                readingSecondsLeft = minutes * 60
                            } label: {
                                Text("\(minutes) 分钟")
                            }
                        }
                    } label: {
                        Text(getSecondsLeftString())
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .frame(width: timerWidth)
                    }
                }
                .onReceive(timer) { time in
                    if readingSecondsLeft != 0 && readingStatus == .on {
                        readingSecondsLeft -= 1
                        if readingSecondsLeft == 0 {
                            readingStatus = .paused
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color(uiColor: UIColor.secondarySystemBackground).opacity(0.9))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary, lineWidth: 0.2))
                        .frame(width: width, height: height)
                )
                .frame(width: width, height: height)
                .offset(x: dragOffset.width + position.width, y: dragOffset.height + position.height)
                .onAppear {
                    position.width = proxy.frame(in: .local).maxX - width
                    position.height = proxy.frame(in: .local).maxY - height
                }
                .highPriorityGesture(
                    DragGesture()
                        .onChanged({ value in
                            withAnimation {
                                dragOffset = value.translation
                            }
                        })
                        .onEnded({ value in
                            withAnimation {
                                position.width += value.translation.width
                                position.height += value.translation.height
                                dragOffset = .zero

                                // Calculate x position.
                                if position.width + width / 2 < proxy.size.width / 2 {
                                    position.width = .zero
                                } else {
                                    position.width = proxy.size.width - width
                                }

                                // Calculate y position.
                                if position.height < .zero {
                                    position.height = .zero
                                } else if position.height > proxy.size.height - height {
                                    position.height = proxy.size.height - height
                                }
                            }
                        })
                )
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .padding()
        } : nil
    }
}
