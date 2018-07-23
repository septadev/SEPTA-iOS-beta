//
//  NSMutableAttributedStringExtensions.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/18/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, _ font: UIFont = UIFont.boldSystemFont(ofSize: 14)) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: font]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)

        return self
    }

    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)

        return self
    }
}
