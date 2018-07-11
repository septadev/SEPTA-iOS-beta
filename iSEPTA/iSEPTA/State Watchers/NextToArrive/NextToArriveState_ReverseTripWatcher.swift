//
//  NextToArriveState_ReverseTripWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol NextToArriveReverseTripWatcherDelegate: AnyObject {
    func nextToArriveReverseTripStatusChanged(status: NextToArriveReverseTripStatus)
}

class NextToArriveState_ReverseTripWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = NextToArriveReverseTripStatus

    weak var delegate: NextToArriveReverseTripWatcherDelegate? 

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.reverseTripStatus }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.nextToArriveReverseTripStatusChanged(status: state)
    }
}

