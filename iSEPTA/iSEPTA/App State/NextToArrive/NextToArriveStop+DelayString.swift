//
//  NextToArriveStop+DelayString.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension NextToArriveStop {
    func generateDelayString(prefixString: String) -> String? {
        let defaultString = "Scheduled"
        guard hasRealTimeData else { return defaultString }

        guard let delayMinutes = delayMinutes else { return defaultString }

        let delayString: String?
        switch delayMinutes {
        case let delay where delay <= 0:
            delayString = "\(prefixString)On Time"

        case let delay where delay > 0:
            delayString = "\(prefixString)\(delay) min late"

        default:
            delayString = defaultString
        }
        return delayString
    }

    private func generateTimeToDeparture() -> Date {
        let sortedDates = [self.arrivalTime, self.departureTime].sorted()
        var firstDate = sortedDates[0]
        if let delayMinutes = self.delayMinutes, hasRealTimeData {
            var components = DateComponents()
            components.minute = delayMinutes
            firstDate = Calendar.current.date(byAdding: components, to: firstDate)!
        }
        return firstDate
    }

    func generateTimeToDepartureString() -> String? {
        let firstDate = generateTimeToDeparture()
        return DateFormatters.formatTimeFromNow(date: firstDate)
    }

    func generateTimeToDepartureAccessibilityString() -> String? {
        let firstDate = generateTimeToDeparture()
        let originalUnitsStyle = DateFormatters.durationFormatter.unitsStyle
        DateFormatters.durationFormatter.unitsStyle = .full
        let accessibilityString = DateFormatters.formatTimeFromNow(date: firstDate)
        DateFormatters.durationFormatter.unitsStyle = originalUnitsStyle
        return accessibilityString
    }

    func generateOnTimeColor() -> UIColor {
        guard let tripDelayMinutes = self.delayMinutes, self.hasRealTimeData else { return SeptaColor.transitIsScheduled }

        if tripDelayMinutes > 0 {
            return SeptaColor.transitIsLate
        } else {
            return SeptaColor.transitOnTime
        }
    }
}
