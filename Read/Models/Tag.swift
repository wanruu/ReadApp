//
//  Tag.swift
//  Read
//
//  Created by wanruuu on 18/8/2024.
//

import Foundation
import SwiftData


@Model
final class Tag {
    var name: String  // Tag name
    // TODO: Include more features

    init(name: String) {
        self.name = name
    }
}
