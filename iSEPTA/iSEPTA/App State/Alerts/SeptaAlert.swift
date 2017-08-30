//
//  SeptaAlert.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

struct SeptaAlert {
    let advisory: Bool
    let alert: Bool
    let detour: Bool
    let weather: Bool

    init(advisory: Bool, alert: Bool, detour: Bool, weather: Bool) {
        self.advisory = advisory
        self.alert = alert
        self.detour = detour
        self.weather = weather
    }

    func imagesForAlert() -> [UIImage] {
        var imageArray = [UIImage?]()
        if advisory {
            imageArray.append(UIImage(named: "advisoryAlert"))
        }
        if alert {
            imageArray.append(UIImage(named: "alertAlert"))
        }
        if detour {
            imageArray.append(UIImage(named: "detourAlert"))
        }
        if weather {
            imageArray.append(UIImage(named: "weatherAlert"))
        }
        return imageArray.flatMap { $0 }
    }
}

extension SeptaAlert: Equatable {}
func ==(lhs: SeptaAlert, rhs: SeptaAlert) -> Bool {
    var areEqual = true

    areEqual = lhs.advisory == rhs.advisory
    guard areEqual else { return false }

    areEqual = lhs.alert == rhs.alert
    guard areEqual else { return false }

    areEqual = lhs.detour == rhs.detour
    guard areEqual else { return false }

    areEqual = lhs.weather == rhs.weather
    guard areEqual else { return false }

    return areEqual
}
