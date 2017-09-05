//
//  LocationServicesListener.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class LocationServicesListener: StoreSubscriber {
    typealias StoreSubscriberStateType = LocationState

    weak var delegate: UpdateableFromViewModel?

    public init() {
        subscribe()
    }

    func newState(state: LocationState) {

        delegate?.updateActivityIndicator(animating: false)
        if let errorMessage = state.errorMessage {
            delegate?.displayErrorMessage(message: errorMessage, shouldDismissAfterDisplay: false)
        }
    }

    deinit {
        unsubscribe()
    }
}

extension LocationServicesListener: SubscriberUnsubscriber {

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.locationState
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
