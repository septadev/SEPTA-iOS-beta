//
//  FavoriteState_ScheduleRequestWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/20/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class FavoriteState_ScheduleRequestWatcher: BaseScheduleRequestWatcher {
    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.nextToArriveScheduleRequest }
        }
    }
}
