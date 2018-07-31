//
//  WeekOfDayView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class WeekOfDayView: UIView {
    struct Keys {
        struct Sunday {
            static let on = "Sunday_On"
            static let off = "Sunday_Off"
        }

        struct Monday {
            static let on = "Monday_On"
            static let off = "Monday_Off"
        }

        struct Tuesday {
            static let on = "Tuesday_On"
            static let off = "Tuesday_Off"
        }

        struct Wednesday {
            static let on = "Wednesday_On"
            static let off = "Wednesday_Off"
        }

        struct Thursday {
            static let on = "Thursday_On"
            static let off = "Thursday_Off"
        }

        struct Friday {
            static let on = "Friday_On"
            static let off = "Friday_Off"
        }

        struct Saturday {
            static let on = "Saturday_On"
            static let off = "Saturday_Off"
        }
    }

    @IBOutlet var dividerView: UIView! {
        didSet {
            dividerView.backgroundColor = SeptaColor.gray_198
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 54)
    }
}
