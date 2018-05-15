//
//  ConstraintsToggle.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ConstraintsToggle: NSObject {
    let activeConstraint: NSLayoutConstraint
    let inactiveConstraint: NSLayoutConstraint

    init(activeConstraint: NSLayoutConstraint, inactiveConstraint: NSLayoutConstraint) {
        self.activeConstraint = activeConstraint
        self.inactiveConstraint = inactiveConstraint
    }

    func toggleConstraints(inView view: UIView) -> ConstraintsToggle {
        activeConstraint.isActive = false
        inactiveConstraint.isActive = true
        view.setNeedsLayout()

        UIView.animate(withDuration: 0.20) {
            view.layoutIfNeeded()
        }
        return ConstraintsToggle(activeConstraint: inactiveConstraint, inactiveConstraint: activeConstraint)
    }
}
