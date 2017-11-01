//
//  NextToArriveStop+DelayString.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

extension NextToArriveStop {
    func generateDelayString() -> String? {
        let defaultString = "Scheduled"
        guard hasRealTimeData else { return defaultString }

        guard let delayMinutes = delayMinutes else { return defaultString }

        let delayString: String?
                switch delayMinutes {
                    case let delay where delay < 0:
                    let absoluteDelay = abs(delay)
                    delayString = "Status: \(absoluteDelay) min early"

                    case 0:
                    delayString = "Status: On Time"

                    case  let delay where delay > 0:
                    delayString = "Status: \(delay) min late"

                    default:
                    delayString = defaultString
                }
        return delayString
    }

}
