//
//  UserPreferenceKey.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum UserPreferenceKeys: String {
    case preferredTransitMode
    case favorites

    func defaultValue() -> String? {
        switch self {
        case .preferredTransitMode:
            return TransitMode.rail.rawValue
        default:
            return nil
        }
    }
}
