//
//  Extension.swift
//  Read
//
//  Created by wanruuu on 13/8/2024.
//

import SwiftUI
import UniformTypeIdentifiers


// MARK: Allow swipe back to last navigation view
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


// MARK: Define color
extension Color {
    public static let readingBackground = Color("ReadingDefault/BackgroundColor")
    public static let readingForeground = Color("ReadingDefault/ForegroundColor")
}

extension UIColor {
    public static let readingBackground = UIColor(named: "ReadingDefault/BackgroundColor")
    public static let readingForeground = UIColor(named: "ReadingDefault/ForegroundColor")
}


// MARK: Accept file from other app
extension Notification.Name {
    static let didReceiveSharedData = Notification.Name("didReceiveSharedData")
}


// MARK: Int & String extension
extension Int {
    var fileSizeDescription: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self))
        return string
    }
}

extension String: Identifiable {
    public var id: String { self }
}
