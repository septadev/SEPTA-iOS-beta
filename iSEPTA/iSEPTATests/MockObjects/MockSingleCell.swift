//
//  MockSingleCell.swift
//  iSEPTATests
//
//  Created by Mark Broski on 8/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
@testable import Septa

class MockSingleCell: SingleStringDisplayable {
    var textColor: UIColor! = UIColor.clear
    var labelText: String! = ""
    var accessoryType: CellDecoration = .detailButton

    func setTextColor(_ color: UIColor) {
        textColor = color
    }

    func setLabelText(_ text: String?) {
        labelText = text
    }

    func setAccessoryType(_ accessoryType: CellDecoration) {
        self.accessoryType = accessoryType
    }
}
