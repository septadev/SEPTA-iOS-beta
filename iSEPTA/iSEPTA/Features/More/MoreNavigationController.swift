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
        initializeNavStackState()
        let stateProvider = MoreNavigationControllerStateProvider()
        stateProvider.navigationController = self
        stateProvider.subscribe()
        super.stateProvider = stateProvider
    }

    func initializeNavStackState() {
        currentStackState = NavigationStackState(viewControllers: [.moreViewController], modalViewController: nil)

        let action = InitializeNavigationState(navigationController: .more, navigationStackState: currentStackState, description: "Initializing stack state for more")
        store.dispatch(action)
    }
}
