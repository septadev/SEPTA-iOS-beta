//
//  NextToArriveReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct NextToArriveReducer {
    static func main(action: Action, state: NextToArriveState?) -> NextToArriveState {
        if let state = state {
            guard let action = action as? NextToArriveAction else { return state }
            return reduceNextToArriveAction(action: action, state: state)
        } else {
            return NextToArriveState()
        }
    }

    static func reduceNextToArriveAction(action _: NextToArriveAction, state: NextToArriveState) -> NextToArriveState {
        var nextToArriveState = state

        return nextToArriveState
    }
}
