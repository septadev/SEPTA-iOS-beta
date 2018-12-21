//
//  PushNotificationTripDetailData+DelayString.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension PushNotificationTripDetailData {

    func generateDelayString(prefixString: String) -> String? {
        let defaultString = "Scheduled"
        guard let results = results, results > 0 else { return defaultString }

        guard let destinationDelay = destinationDelay else { return defaultString }

        let delayString: String?
        switch destinationDelay {
        case let delay where delay <= 0:
            delayString = "\(prefixString)On Time"

        case let delay where delay > 0:
            delayString = "\(prefixString)\(delay) min late"

        default:
            delayString = defaultString
        }
        return delayString
    }



    func generateOnTimeColor() -> UIColor {
        guard let results = results, results > 0,
        let destinationDelay = destinationDelay else { return SeptaColor.transitIsScheduled }

        if destinationDelay > 0 {
            return SeptaColor.transitIsLate
        } else {
            return SeptaColor.transitOnTime
        }
    }
}






