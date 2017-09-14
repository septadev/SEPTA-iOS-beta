//
//  BlueGradientView.swift
//  FavoritesCell
//
//  Created by Mark Broski on 9/14/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation
import UIKit
class BlueGradientView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingGradientView(frame: rect)
    }
}
