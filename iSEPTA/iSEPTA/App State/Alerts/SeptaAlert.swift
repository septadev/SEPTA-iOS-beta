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

struct AlertViewElement {
    let text: String
    let image: UIImage
}

struct SeptaAlert {
    let advisory: Bool
    let alert: Bool
    let detour: Bool
    let weather: Bool
    let suspended: Bool

    init(advisory: Bool = false, alert: Bool = false, detour: Bool = false, weather: Bool = false, suspended: Bool = false) {
        self.advisory = advisory
        self.alert = alert
        self.detour = detour
        self.weather = weather
        self.suspended = suspended
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
        if suspended {
            imageArray.append(UIImage(named: "suspendedAlert"))
        }
        return imageArray.compactMap { $0 }
    }

    func stringsForAlert() -> [String] {
        var stringArray = [String]()
        if advisory {
            stringArray.append("Advisory")
        }
        if alert {
            stringArray.append("Alert")
        }
        if detour {
            stringArray.append("Detour")
        }
        if weather {
            stringArray.append("Weather")
        }
        if weather {
            stringArray.append("Suspended")
        }
        return stringArray
    }

    func alertViewElements() -> [AlertViewElement] {
        let images = imagesForAlert()
        let strings = stringsForAlert()

        var elements = [AlertViewElement]()

        for (index, _) in images.enumerated() {
            elements.append(AlertViewElement(text: strings[index], image: images[index]))
        }
        return elements
    }
}

extension SeptaAlert: Equatable {}
func == (lhs: SeptaAlert, rhs: SeptaAlert) -> Bool {
    var areEqual = true

    areEqual = lhs.advisory == rhs.advisory
    guard areEqual else { return false }

    areEqual = lhs.alert == rhs.alert
    guard areEqual else { return false }

    areEqual = lhs.detour == rhs.detour
    guard areEqual else { return false }

    areEqual = lhs.weather == rhs.weather
    guard areEqual else { return false }

    areEqual = lhs.suspended == rhs.suspended
    guard areEqual else { return false }

    return areEqual
}
