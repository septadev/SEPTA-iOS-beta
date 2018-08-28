//
//  SelectStopNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class SelectStopNavigationController: UINavigationController, IdentifiableController, IdentifiableNavController {
    var navController: NavigationController = NavigationController.selectStop
    let viewController: ViewController = .selectStopNavigationController
}
