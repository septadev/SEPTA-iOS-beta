//
//  TripHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TripHeaderView: UIView {

    @IBOutlet weak var pillView: UIView! {
        didSet {
            pillView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var alertStackView: UIStackView!
}
