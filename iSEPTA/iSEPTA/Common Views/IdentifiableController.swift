// Septa. 2017

import Foundation
import UIKit

protocol IdentifiableController {

    var viewController: ViewController { get }
}

extension IdentifiableController where Self: UIViewController {

    func backButtonPopped(toParentViewController parent: UIViewController?) {

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(viewController: viewController, description: "view controller has been popped by the back Button")
            store.dispatch(action)
        }
    }
}

protocol IdentifiableNavController: class {

    var navController: NavigationController { get }
}

extension IdentifiableNavController where Self: UINavigationController {}
