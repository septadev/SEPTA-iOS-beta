//
//  DatabaseReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import ReSwift

struct DatabaseReducer {

    static func main(action: Action, state: DatabaseState?) -> DatabaseState {
        if let state = state {
            guard let action = action as? DatabaseAction else { return state }
            return reduceNewDatabaseState(action: action, state: state)
        } else {
            return .notLoaded
        }
    }

    static func reduceNewDatabaseState(action: DatabaseAction, state: DatabaseState) -> DatabaseState {
        var newState = state
        switch action {
        case let action as NewDatabaseState:
            newState = action.databaseState
        default:
            break
        }

        return newState
    }
}
