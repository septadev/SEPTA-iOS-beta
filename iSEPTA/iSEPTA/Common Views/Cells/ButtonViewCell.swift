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
    weak var lastCellDelegate: LastCellDelegate?
    var buttonText: String = ""
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawRedButton(frame: rect, redButtonText: buttonText, enabled: enabled)
    }

    @objc override var frame: CGRect {

        didSet {
            updateLastCellDelegate()
        }
    }

    func updateLastCellDelegate() {
        guard let lastCellDelegate = lastCellDelegate else { return }
        let bottom = frame.origin.y + frame.size.height
        lastCellDelegate.lastCellBottomSet(bottom: bottom)
    }

    var enabled: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
}
