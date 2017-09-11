//
//  NoConnectionCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NoConnectionCell: UITableViewCell {

    @IBOutlet weak var departingWhenLabel: UILabel!
    @IBOutlet weak var departingView: UIView! {
        didSet {
            departingView.layer.cornerRadius = 2.0
            departingView.layer.borderWidth = 1.0
        }
    }

    @IBOutlet weak var endStopLabel: UILabel!

    @IBOutlet weak var onTimeLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
}
