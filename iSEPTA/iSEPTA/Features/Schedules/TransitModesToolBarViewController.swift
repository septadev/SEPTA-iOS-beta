//
//  TransitModesToolBarViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class TransitModesToolbarViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = TransitMode?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToStateUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromStateUpdates()
    }

    func subscribeToStateUpdates() {
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func unsubscribeFromStateUpdates() {
        store.unsubscribe(self)
    }

    func filterSubscription(state: AppState) -> TransitMode? {
        return state.scheduleState.scheduleRequest?.transitMode
    }

    func newState(state _: StoreSubscriberStateType) {
    }
}
