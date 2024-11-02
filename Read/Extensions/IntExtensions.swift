//
//  IntExtensions.swift
//  Read
//
//  Created by wanruuu on 2/11/2024.
//

import UniformTypeIdentifiers


extension Int {
    var fileSizeDescription: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self))
        return string
    }
}
