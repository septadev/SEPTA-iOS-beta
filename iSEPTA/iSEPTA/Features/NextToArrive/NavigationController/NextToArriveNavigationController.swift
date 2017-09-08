//
//  NextToArriveNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveNavigationController: BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNavStackState()
    }

    func initializeNavStackState() {
        currentStackState = NavigationStackState(viewControllers: [.nextToArriveController], modalViewController: nil)

        let action = InitializeNavigationState(navigationController: .nextToArrive, navigationStackState: currentStackState, description: "Initializing stack state for next to arrive")
        store.dispatch(action)
    }
}
