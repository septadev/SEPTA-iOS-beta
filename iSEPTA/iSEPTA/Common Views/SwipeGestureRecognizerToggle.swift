//
//  SwipeGestureRecognizerToggle.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SwipeGestureRecognizerToggle: NSObject {
    let activeRecognizer: UISwipeGestureRecognizer
    let inactiveRecognizer: UISwipeGestureRecognizer

    init(activeRecognizer: UISwipeGestureRecognizer, inactiveRecognizer: UISwipeGestureRecognizer) {
        self.activeRecognizer = activeRecognizer
        self.inactiveRecognizer = inactiveRecognizer
    }

    func toggleRecognizers() -> SwipeGestureRecognizerToggle {
        activeRecognizer.isEnabled = false
        inactiveRecognizer.isEnabled = true

        return SwipeGestureRecognizerToggle(activeRecognizer: inactiveRecognizer, inactiveRecognizer: activeRecognizer)
    }
}
