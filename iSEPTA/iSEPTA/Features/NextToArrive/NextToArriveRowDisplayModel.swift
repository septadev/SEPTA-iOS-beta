//
//  NextToArriveRowDisplayModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

struct NextToArriveRowDisplayModel {
    let text: String?
    let cellId: String
    let shouldFillCell: Bool
    let isSelectable: Bool
    let targetController: ViewController?
    let pillColor: UIColor?
    let showSearchIcon: Bool
    let fontWeight: UIFont.Weight
    let searchIconName: String

    init(text: String? = nil,
         cellId: String,
         shouldFillCell: Bool = false,
         isSelectable: Bool = false,
         targetController: ViewController? = nil,
         pillColor: UIColor? = nil,
         showSearchIcon: Bool = false,
         fontWeight: UIFont.Weight = UIFont.Weight.regular,
         searchIconName: String = "SearchIcon") {
        self.text = text
        self.cellId = cellId
        self.shouldFillCell = shouldFillCell
        self.isSelectable = isSelectable
        self.targetController = targetController
        self.pillColor = pillColor
        self.showSearchIcon = showSearchIcon
        self.fontWeight = fontWeight
        self.searchIconName = searchIconName
    }
}
