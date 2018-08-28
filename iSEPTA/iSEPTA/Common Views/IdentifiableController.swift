// Septa. 2017

import Foundation
import UIKit

extension IdentifiableNavController where Self: UIViewController {}

protocol IdentifiableController {
    var viewController: ViewController { get }
}

protocol IdentifiableNavController: class {
    var navController: NavigationController { get }
}

extension IdentifiableNavController where Self: UINavigationController {}
