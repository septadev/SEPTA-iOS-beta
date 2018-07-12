//
//  FavoriteState_NextToArriveReverseTripStatusWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift


class FavoriteState_NextToArriveReverseTripStatusWatcher: NextToArriveState_ReverseTripStatusWatcher {
    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.nextToArriveReverseTripStatus}
        }
    }
}



