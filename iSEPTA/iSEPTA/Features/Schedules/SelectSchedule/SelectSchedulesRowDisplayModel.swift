//
//  SelectSchedulesRowDisplayModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

struct SelectSchedulesRowDisplayModel {
    let text: String
    let shouldFillCell: Bool
    let isSelectable: Bool
    let targetController: ViewController
    let pillColor: UIColor
    let showSearchIcon: Bool
    let fontWeight: UIFont.Weight

    init(text: String, shouldFillCell: Bool, isSelectable: Bool, targetController: ViewController, pillColor: UIColor, showSearchIcon: Bool = false, fontWeight: UIFont.Weight = UIFont.Weight.regular) {
        self.text = text
        self.shouldFillCell = shouldFillCell
        self.isSelectable = isSelectable
        self.targetController = targetController
        self.pillColor = pillColor
        self.showSearchIcon = showSearchIcon
        self.fontWeight = fontWeight
    }
}
