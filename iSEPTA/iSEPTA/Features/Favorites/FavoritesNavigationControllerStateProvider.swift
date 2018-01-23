//
//  FavoritesNavigationControllerStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class FavoritesNavigationControllerStateProvider: NavigationControllerBaseStateProvider {

    @IBOutlet var navigationController: BaseNavigationController!

    override func newState(state: StoreSubscriberStateType) {
        guard let newState = state, let newStackState = newState[.favorites] else { return }
        navigationController.newStackState(newStackState)
    }
}
