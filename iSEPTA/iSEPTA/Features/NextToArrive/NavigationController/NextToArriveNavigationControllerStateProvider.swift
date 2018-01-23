//
//  NextToArriveNavigationControllerStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class NextToArriveNavigationControllerStateProvider: NavigationControllerBaseStateProvider {

    @IBOutlet var navigationController: BaseNavigationController!

    override func newState(state: StoreSubscriberStateType) {
        guard let newState = state, let newStackState = newState[.nextToArrive] else { return }
        navigationController.newStackState(newStackState)
    }
}
