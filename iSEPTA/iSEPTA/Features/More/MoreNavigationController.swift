//
//  AlertsNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class MoreNavigationController: BaseNavigationController, IdentifiableNavController, IdentifiableController {
    var navController: NavigationController = .more
    var viewController: ViewController = .moreNavigationController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
    }

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.appStackState[.more] }
        }
    }

    override func resetViewState(resetViewState: ResetViewState?) {
        guard let resetViewState = resetViewState else { return }

        var viewControllers = [UIViewController]()

        switch resetViewState.viewController {
        case .customPushNotificationsController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.moreViewController, .managePushNotficationsController, .customPushNotificationsController])
        case .managePushNotficationsController:
            viewControllers = retrieveOrInstantiate(viewControllers: [.moreViewController, .managePushNotficationsController])
        default: break
        }

        self.viewControllers = viewControllers

        store.dispatch(ResetViewStateHandled())
    }
}
