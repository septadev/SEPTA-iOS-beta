//
//  AlertNavigationControllerStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
class MoreNavigationControllerStateProvider: NavigationControllerBaseStateProvider {

    @IBOutlet weak var navigationController: BaseNavigationController!

    override func newState(state: StoreSubscriberStateType) {
        guard let newState = state, let newStackState = newState[.more] else { return }
        navigationController.newStackState(newStackState)
    }
}
