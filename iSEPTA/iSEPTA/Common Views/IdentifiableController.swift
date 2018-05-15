// Septa. 2017

import Foundation
import UIKit

protocol IdentifiableController {

    var viewController: ViewController { get }
}

extension IdentifiableController where Self: UIViewController {

    func backButtonPopped(toParentViewController parent: UIViewController?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15, execute: {
            if parent == nil {
                let action = UserPoppedViewController(viewController: self.viewController, description: "view controller has been popped by the back Button")
                store.dispatch(action)
            }
        })
    }
}

protocol IdentifiableNavController: class {

    var navController: NavigationController { get }
}

extension IdentifiableNavController where Self: UINavigationController {}
