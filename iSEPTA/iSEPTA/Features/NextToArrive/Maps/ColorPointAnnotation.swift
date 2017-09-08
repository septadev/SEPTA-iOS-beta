//
//  ColorPointAnnotation.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor

    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}
