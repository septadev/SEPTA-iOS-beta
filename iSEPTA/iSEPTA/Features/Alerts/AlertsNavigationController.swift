//
//  AlertsNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AlertsNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.appStackState[.alerts] }
        }
    }

    override func resetViewState(resetViewState: ResetViewState?) {
        guard let resetViewState = resetViewState else { return }

        var viewControllers = self.viewControllers

        let identifiableControllers: [ViewController] = self.viewControllers.map {
            guard let controller = $0 as? IdentifiableController else { return .alertsViewController }
            return controller.viewController
        }

        switch resetViewState.viewController {
        case .alertDetailViewController:
            if identifiableControllers != [.alertsViewController, .alertDetailViewController] {
                viewControllers = retrieveOrInstantiate(viewControllers: [.alertsViewController, .alertDetailViewController])
                self.viewControllers = viewControllers
            }
        case .alertsViewController:
            if identifiableControllers != [.alertsViewController] {
                viewControllers = retrieveOrInstantiate(viewControllers: [.alertsViewController])
                self.viewControllers = viewControllers
            }
        default: break
        }

        store.dispatch(ResetViewStateHandled())
    }
}
