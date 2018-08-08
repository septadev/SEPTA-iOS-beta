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

        var viewControllers = [UIViewController]()

        switch resetViewState.viewController {
        case .alertDetailViewController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.alertsViewController, .alertDetailViewController])
        case .alertsViewController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.alertsViewController])
        default: break
        }

        self.viewControllers = viewControllers

        store.dispatch(ResetViewStateHandled())
    }
}
