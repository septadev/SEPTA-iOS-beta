// SEPTA.org, created on 8/2/17.

import Foundation
import UIKit

class Alert {

    static func presentOKAlertFrom(viewController: UIViewController, withTitle title: String, message: String, completion:  (()->())?){
        // create the alert
        let alert = UIAlertController(title: "title", message: message, preferredStyle: UIAlertControllerStyle.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))

        // show the alert
        viewController.present(alert, animated: true, completion: completion)

    }
}
