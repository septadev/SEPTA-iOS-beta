//
//  BaseNavigationBar.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationBar: UINavigationBar {

    override func awakeFromNib() {
        backgroundColor = UIColor.clear
        isTranslucent = true
        barStyle = .black
        shadowImage = UIImage()
        setBackgroundImage(UIImage(), for: .default)
    }
}
