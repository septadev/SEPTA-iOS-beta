//
//  BaseNavigationController+Styling.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .black
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}
