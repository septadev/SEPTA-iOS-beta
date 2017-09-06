// Septa. 2017

import Foundation
import UIKit

class UIAlert {

    static func presentOKAlertFrom(viewController: UIViewController, withTitle title: String, message: String, completion: (() -> Void)? = nil) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { _ in
            completion?()
        })

        // show the alert
        viewController.present(alert, animated: true, completion: nil)
    }

    static func presentComingSoonAlertFrom(_ viewController: UIViewController) {
        presentOKAlertFrom(viewController: viewController, withTitle: "Septa", message: "This cool feature is coming soon!")
    }
}
