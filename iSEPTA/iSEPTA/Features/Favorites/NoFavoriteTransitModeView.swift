//
//  NoFavoriteTransitView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

@IBDesignable
class NoFavoriteTransitModeView: UIView {

    @IBOutlet weak var transitModeIcon: UIImageView!
    @IBOutlet weak var transitModeName: UILabel!

    var transitMode: TransitMode! {
        didSet {
            transitModeIcon.image = transitMode.noFavoriteIcon()
            transitModeName.text = transitMode.name()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 25, height: 50)
    }
}
