//
//  UIColor+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {
    static func toPercent(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / CGFloat(255.0),
                       green: CGFloat(g) / CGFloat(255.0),
                       blue: CGFloat(b) / CGFloat(255.0),
                       alpha: a)
    }
}
