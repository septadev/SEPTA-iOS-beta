//
//  String+HTML.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension String {
    var htmlAttributedString: NSAttributedString? {
        let htmlString = "<html>\(self)</html>"
        do {
            guard let data = htmlString.data(using: .utf8) else { return nil }
            return try NSAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            ], documentAttributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}
