//
//  NoRouteNeededCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import UIKit

class NoRouteNeededCell: UITableViewCell, SingleStringDisplayable {

    @IBOutlet weak var label: UILabel!
    func setTextColor(_ color: UIColor) {
        label.textColor = color
    }

    func setLabelText(_ text: String?) {
        label.text = text
    }

    func setAccessoryType(_ accessoryType: UITableViewCellAccessoryType) {
        self.accessoryType = accessoryType
    }

    func setShouldFill(_: Bool) {
    }

    func setEnabled(_: Bool) {
    }
}
