//
//  AlertNavigationControllerStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
class AlertNavigationControllerStateProvider: NavigationControllerBaseStateProvider {

    @IBOutlet var navigationController: BaseNavigationController!

    override func newState(state: StoreSubscriberStateType) {
        guard let newState = state, let newStackState = newState[.alerts] else { return }
        navigationController.newStackState(newStackState)
    }
}
