//
//  NextToArriveState_ReverseTripWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

protocol NextToArriveReverseTripWatcher: AnyObject {
    func nextToArriveReverseTripStatusChanged(status: NextToArriveReverseTripStatus)
}

class NextToArriveState_ReverseTripWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = NextToArriveReverseTripStatus

    weak var delegate: NextToArriveReverseTripWatcher? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.reverseTripStatus }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.nextToArriveReverseTripStatusChanged(status: state)
    }
}

// class NextToArriveFavorite_ReverseTripWatcher: BaseWatcher, StoreSubscriber {
//
//    typealias StoreSubscriberStateType = Bool
//
//    weak var delegate: NextToArriveReverseTripWatcher? {
//        didSet {
//            subscribe()
//        }
//    }
//
//    func subscribe() {
//        //        store.subscribe(self) {
//        //            //$0.select { $0.favoritesState.nextToArriveFavorite. }
//        //        }
//    }
//
//    func newState(state: StoreSubscriberStateType) {
//        delegate?.nextToArriveReverseTripChanged(isReversed: state)
//    }
// }
