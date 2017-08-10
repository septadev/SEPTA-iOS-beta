//
//  IdentifiableController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/9/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol IdentifiableController {

    static var viewController: ViewController { get set }
}

extension IdentifiableController where Self: UIViewController {}

protocol IdentifiableNavController: class {

    static var navController: NavigationController { get set }
}

extension IdentifiableNavController where Self: UINavigationController {}
