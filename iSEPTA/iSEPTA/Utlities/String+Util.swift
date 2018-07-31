//
//  String+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 1/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension Optional where Wrapped == String {
    var isBlank: Bool {
        return self?.isEmpty ?? true
    }
}

extension String {
    func attributedStringWithSystemFont(ofSize size: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let font = UIFont.systemFont(ofSize: size)
        attributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }

    func attributedStringWithSystemFont(ofSize size: CGFloat, lineSpacing: CGFloat, characterSpacing: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        return NSAttributedString(string: "text", attributes: [
            .kern: characterSpacing,
            .font: UIFont.systemFont(ofSize: size),
            .paragraphStyle: paragraphStyle,
        ]
        )
    }

    func toCGFloat() -> CGFloat? {
        guard let doubleValue = NumberFormatters.floatFormatter.number(from: self)?.doubleValue else { return nil }
        return CGFloat(doubleValue)
    }

    func fullrange() -> NSRange {
        return NSMakeRange(0, count)
    }

    func attributed(
        fontSize: CGFloat,
        fontWeight: UIFont.Weight = .regular,
        textColor: UIColor = UIColor.black,
        alignment: NSTextAlignment = .left,
        kerning: CGFloat? = 0,
        lineHeight: CGFloat? = nil) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        if let lineHeight = lineHeight {
            paragraphStyle.minimumLineHeight = lineHeight
        }
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .foregroundColor: textColor,
            .kern: kerning ?? 0,
            .paragraphStyle: paragraphStyle,
        ], range: fullrange())

        return attributedString
    }
}
