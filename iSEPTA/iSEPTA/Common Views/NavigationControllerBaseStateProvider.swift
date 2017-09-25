//
//  BaseNavigationControllerStateProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class NavigationControllerBaseStateProvider: NSObject, StoreSubscriber {
    typealias StoreSubscriberStateType = [NavigationController: NavigationStackState]?

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.navigationState.appStackState
            }.skipRepeats {
                if let lhsState = $0, let rhsState = $1 {
                    return lhsState == rhsState
                }
                return false
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }

    func newState(state _: StoreSubscriberStateType) {
    }
}
