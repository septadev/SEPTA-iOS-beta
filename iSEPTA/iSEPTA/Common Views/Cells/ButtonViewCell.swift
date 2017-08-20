//
//  ButtonViewCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ButtonViewCell: UITableViewCell {

    var buttonText: String = ""
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawRedButton(frame: rect, redButtonText: buttonText, enabled: enabled)
    }

    var enabled: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
}
