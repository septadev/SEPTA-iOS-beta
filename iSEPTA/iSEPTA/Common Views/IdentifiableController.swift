// Septa. 2017

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
