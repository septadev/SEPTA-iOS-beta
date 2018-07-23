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

enum ColorPointAnnotationType: String {
    case start
    case end

    func pinColor() -> UIColor {
        switch self {
        case .start: return UIColor.green
        case .end: return UIColor.red
        }
    }
}

class ColorPointAnnotation: MKPointAnnotation {

    let colorPointAnnotationType: ColorPointAnnotationType

    init(colorPointAnnotationType: ColorPointAnnotationType) {
        self.colorPointAnnotationType = colorPointAnnotationType
        super.init()
    }
}
