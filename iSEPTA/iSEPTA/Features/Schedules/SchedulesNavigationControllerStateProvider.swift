//
//  FavoritesNavigationControllerStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class SchedulesNavigationControllerStateProvider: NavigationControllerBaseStateProvider {

    @IBOutlet var navigationController: BaseNavigationController!

    override func newState(state: StoreSubscriberStateType) {
        guard let newState = state, let newStackState = newState[.schedules] else { return }
        navigationController.newStackState(newStackState)
    }
}
