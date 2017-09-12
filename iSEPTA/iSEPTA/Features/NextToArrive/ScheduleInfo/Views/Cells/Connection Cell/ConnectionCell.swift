//
//  ConnectionCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ConnectionCell: UITableViewCell {
}

class BlueGradientView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingGradientView(frame: rect)
    }
}
