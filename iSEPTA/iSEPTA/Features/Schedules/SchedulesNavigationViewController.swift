//
//  SchedulesNavigationViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SchedulesNavigationController: UINavigationController, StoreSubscriber {
    typealias StoreSubscriberStateType = NavigationState

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.dispatch(SwitchFeatureCompleted(activeFeature: .schedules))
    }

    func filterSubscription(state: AppState) -> NavigationState {
        return state.navigationState
    }

    func newState(state _: StoreSubscriberStateType) {
    }
}
