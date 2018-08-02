//
//  DayOfWeekImageView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/31/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class DayOfWeekImageView: UIImageView {
    @IBInspectable var dayOfWeekString: String = "unknown"

    func respondToState(selectedDaysOfWeek: DaysOfWeekOptionSet) {
        isHighlighted = selectedDaysOfWeek.contains(dayOfWeek)
    }

    var dayOfWeek: DaysOfWeekOptionSet {
        switch dayOfWeekString {
        case "unknown": return DaysOfWeekOptionSet.unknown
        case "monday": return DaysOfWeekOptionSet.monday
        case "tuesday": return DaysOfWeekOptionSet.tuesday
        case "wednesday": return DaysOfWeekOptionSet.wednesday
        case "thursday": return DaysOfWeekOptionSet.thursday
        case "friday": return DaysOfWeekOptionSet.friday
        case "saturday": return DaysOfWeekOptionSet.saturday
        case "sunday": return DaysOfWeekOptionSet.sunday
        default: return DaysOfWeekOptionSet.unknown
        }
    }
}
