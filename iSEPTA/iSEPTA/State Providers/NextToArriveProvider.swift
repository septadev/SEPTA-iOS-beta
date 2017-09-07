//
//  NextToArriveProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import SeptaSchedule
import ReSwift

class NextToArriveProvider: StoreSubscriber {

    typealias StoreSubscriberStateType = FavoritesState

    static let sharedInstance = NextToArriveProvider()

    private init() {

        subscribe()
    }

    deinit {
        unsubscribe()
    }

    func newState(state _: FavoritesState) {
    }
}

extension NextToArriveProvider: SubscriberUnsubscriber {

    func unsubscribe() {
        store.unsubscribe(self)
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState
            }.skipRepeats { $0 == $1 }
        }
    }
}
