//
//  TransitViewDataProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

class TransitViewDataProvider: StoreSubscriber {
    static let sharedInstance = TransitViewDataProvider()

    typealias StoreSubscriberStateType = Bool

    init() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.transitViewState.refreshTransitViewRoutes }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state {
            retrieveTransitViewRoutes()
        }
    }

    func retrieveTransitViewRoutes() {
        TransitRoutesCommand.sharedInstance.routes { routes, _ in
            var routes = routes ?? [TransitRoute]()
            routes = routes.filter { $0.routeId != "NHSL" } // remove this route from transit view
            let action = TransitViewRoutesLoaded(routes: routes, description: "TransitView routes loaded from database")
            store.dispatch(action)
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
