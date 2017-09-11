//
//  NextToArriveInfoViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class NextToArriveInfoViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = [NextToArriveTrip]

    var delegate: UpdateableFromViewModel! {
        didSet {
            subscribe()
        }
    }

    var trips = [NextToArriveTrip]()

    func newState(state: StoreSubscriberStateType) {
        trips = state
        delegate.viewModelUpdated()
    }

    deinit {
        unsubscribe()
    }
}

extension NextToArriveInfoViewModel { // Table View
    func numberOfSections() -> Int {

        return 1
    }

    func numberOfRows() -> Int {
        return trips.count
    }

    func cellIdAtIndexPath(_: IndexPath) -> String {
        return "noConnectionCell"
    }

    func configureCell(_: UITableViewCell, atIndexPath _: IndexPath) {
    }
}

extension NextToArriveInfoViewModel: SubscriberUnsubscriber {
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.nextToArriveState.nextToArriveTrips
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
