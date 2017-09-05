//
//  SelectStopCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/25/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SelectStopCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    var shouldFill: Bool = false
    var enabled: Bool = false

    @IBOutlet weak var distanceLabel: UILabel! {
        didSet {
            distanceLabel.isHidden = true
        }
    }
}

extension SelectStopCell: SingleStringDisplayable {
    func setLabelText(_ text: String?) {
        label?.text = text
    }

    func setAccessoryType(_ accessoryType: UITableViewCellAccessoryType) {
        self.accessoryType = accessoryType
    }

    func setShouldFill(_ shouldFill: Bool) {
        self.shouldFill = shouldFill
    }

    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
    }

    func setTextColor(_ color: UIColor) {
        textLabel?.textColor = color
    }
}
