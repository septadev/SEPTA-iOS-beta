//
//  FaresNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FaresNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        initializeNavStackState()
        let stateProvider = FaresNavigationControllerStateProvider()
        stateProvider.navigationController = self
        stateProvider.subscribe()
        super.stateProvider = stateProvider
    }

    func initializeNavStackState() {
        currentStackState = NavigationStackState(viewControllers: [.faresViewController], modalViewController: nil)

        let action = InitializeNavigationState(navigationController: .fares, navigationStackState: currentStackState, description: "Initializing stack state for Fares")
        store.dispatch(action)
    }
}
