//
//  BookTableCell.swift
//  Read
//
//  Created by wanruuu on 16/8/2024.
//

import SwiftUI


class BookTableViewCell: UITableViewCell {
    let labelView = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Initialize view
        self.selectionStyle = .none
        self.backgroundColor = UIColor.readingBackground
        labelView.numberOfLines = 0
        labelView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelView)

        // Add constriant
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            labelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            labelView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String, lineSpacing: CGFloat = 12, font: UIFont, fgColor: UIColor? = UIColor.readingForeground) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        labelView.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
        labelView.font = font
        labelView.textColor = fgColor
    }
}
