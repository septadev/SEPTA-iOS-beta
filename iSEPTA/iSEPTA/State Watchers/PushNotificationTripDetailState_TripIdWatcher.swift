//
//  PushNotificationTripDetailState_TripIdWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol PushNotificationTripDetailState_TripIdWatcherDelegate: AnyObject {
    func pushNotificationTripDetailState_TripIdUpdated(tripId: String)
}

class PushNotificationTripDetailState_TripIdWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    weak var delegate: PushNotificationTripDetailState_TripIdWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.pushNotificationTripDetailState.tripId != nil }
        }
    }

    func newState(state _: StoreSubscriberStateType) {
//        delegate?.tripDetailState_TripDetailsExistUpdated(bool: state)
    }
}
