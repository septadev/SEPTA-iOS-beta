//
//  NextToArriveReverseTripStatus.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum NextToArriveReverseTripStatus {
    case noReverse
    case didReverse

    func toggle() -> NextToArriveReverseTripStatus {
        let result: NextToArriveReverseTripStatus
        switch self {
            case .noReverse: result = .didReverse
            case .didReverse: result = .noReverse
        }
        return result
    }
}
