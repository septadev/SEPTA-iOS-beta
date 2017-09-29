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

    static func presentYesNoAlertFrom(viewController: UIViewController, withTitle title: String, message: String, completion: (() -> Void)? = nil) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { _ in
            completion?()
        })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default))

        // show the alert
        viewController.present(alert, animated: true, completion: nil)
    }

    static func presentDestructiveYesNoAlertFrom(viewController: UIViewController, withTitle title: String, message: String, completion: (() -> Void)? = nil) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { _ in
            completion?()
        })
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel))

        // show the alert
        viewController.present(alert, animated: true, completion: nil)
    }

    static func presentComingSoonAlertFrom(_ viewController: UIViewController) {
        presentOKAlertFrom(viewController: viewController, withTitle: "SEPTA iOS", message: "This cool feature is coming soon!")
    }
}
