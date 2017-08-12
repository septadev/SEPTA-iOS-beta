//
//  NumberFormatters.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public class NumberFormatters {

    static var logNumberFormatter: NumberFormatter = {

        let formatter = NumberFormatter()
        formatter.positiveFormat = "000"
        return formatter
    }()
}
