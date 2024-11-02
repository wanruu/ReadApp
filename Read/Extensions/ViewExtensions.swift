//
//  ViewExtensions.swift
//  Read
//
//  Created by wanruuu on 2/11/2024.
//

import SwiftUI


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
