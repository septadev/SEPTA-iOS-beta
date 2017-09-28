// Septa. 2017

import Foundation
import UIKit

protocol IdentifiableController {

    var viewController: ViewController { get }
}

extension IdentifiableController where Self: UIViewController {}

protocol IdentifiableNavController: class {

    var navController: NavigationController { get }
}

extension IdentifiableNavController where Self: UINavigationController {}
