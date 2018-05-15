//
//  String+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 1/23/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var isBlank: Bool {
        return self?.isEmpty ?? true
    }
}
