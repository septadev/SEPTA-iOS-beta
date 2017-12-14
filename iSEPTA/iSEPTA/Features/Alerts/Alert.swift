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

    static func presentOKJumpToSchedulesAlert(viewController: UIViewController, withTitle title: String, message: String, completion: (() -> Void)? = nil) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Go to Schedules", style: UIAlertActionStyle.default) { _ in
            let action = SwitchTabs(activeNavigationController: .schedules, description: "Jump to Schedules after error in next to arrive")
            store.dispatch(action)
        })

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { _ in
            completion?()
        })

        // show the alert
        viewController.present(alert, animated: true, completion: nil)
    }

    static func presentComingSoonAlertFrom(_ viewController: UIViewController) {
        presentOKAlertFrom(viewController: viewController, withTitle: "SEPTA iOS", message: "This cool feature is coming soon!")
    }

    static func presentHolidayAlertFrom(viewController: UIViewController, holidaySchedule: HolidaySchedule) {

        guard let message = holidaySchedule.holidayMessage(),
            let onlineSchedules = holidaySchedule.onlineHolidaySchedules(),
            let onlineScheduleController = Bundle.main.loadNibNamed("HolidaySchedule", owner: nil, options: nil)?.first as? HolidayScheduleViewController else { return }

        let alert = UIAlertController(title: "Holiday Schedule", message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Switch to Next To Arrive", style: UIAlertActionStyle.default) { _ in
            let action = SwitchTabs(activeNavigationController: .nextToArrive, description: "Holiday Schedules")
            store.dispatch(action)
        }
        )
        for onlineSchedule in onlineSchedules {
            alert.addAction(UIAlertAction(title: onlineSchedule.label, style: UIAlertActionStyle.default) { _ in
                let request = URLRequest(url: onlineSchedule.url)
                onlineScheduleController.uiWebView.loadRequest(request)
                viewController.present(onlineScheduleController, animated: true, completion: nil)
            })
        }

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { _ in }
        )

        viewController.present(alert, animated: true, completion: nil)
    }
}
