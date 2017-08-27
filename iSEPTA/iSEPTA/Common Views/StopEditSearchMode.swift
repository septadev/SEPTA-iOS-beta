//
//  SearchMode.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

enum StopEditSearchMode {
    case directLookup
    case byAddress
    case directLookupWithAddress

    func textFieldPlaceHolderText(transitMode: TransitMode) -> String? {
        switch self {
        case .directLookup:
            return transitMode.placeholderText()
        case .byAddress:
            return "Enter address to search near"
        case .directLookupWithAddress:
            return nil
        }
    }
}
