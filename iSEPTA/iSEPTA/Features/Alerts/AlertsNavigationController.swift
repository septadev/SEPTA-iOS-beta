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
        initializeNavStackState()
        let stateProvider = AlertNavigationControllerStateProvider()
        stateProvider.navigationController = self
        stateProvider.subscribe()
        super.stateProvider = stateProvider
    }

    func initializeNavStackState() {
        currentStackState = NavigationStackState(viewControllers: [.alertsViewController], modalViewController: nil)

        let action = InitializeNavigationState(navigationController: .alerts, navigationStackState: currentStackState, description: "Initializing stack state for next to arrive")
        store.dispatch(action)
    }
}
