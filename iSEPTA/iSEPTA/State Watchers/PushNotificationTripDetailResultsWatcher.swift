//
//  PushNotificationTripDetailResultsWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol PushNotificationTripDetailState_ResultsDelegateDelegate: AnyObject {
    func pushNotificationTripDetailState_Updated(state: PushNotificationTripDetailState)
}

class PushNotificationTripDetailState_ResultsWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = PushNotificationTripDetailState

    weak var delegate: PushNotificationTripDetailState_ResultsDelegateDelegate? {
        didSet {
            subscribe()
        }
    }

    private func subscribe() {
        store.subscribe(self) {
            $0.select { $0.pushNotificationTripDetailState}
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.pushNotificationTripDetailState_Updated(state: state )
    }
}




