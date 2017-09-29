//
//  LocationReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct MoreReducer {

    static func main(action: Action, state: MoreState?) -> MoreState {
        if let state = state {
            guard let action = action as? MoreAction else { return state }
            return reduceMoreAction(action: action, state: state)
        } else {
            return MoreState()
        }
    }

    static func reduceMoreAction(action: MoreAction, state: MoreState) -> MoreState {
        var moreState = state
        switch action {
        case let action as DisplayURL:
            moreState = reduceDisplayURL(action: action, state: state)
        default:
            break
        }

        return moreState
    }

    static func reduceDisplayURL(action: DisplayURL, state _: MoreState) -> MoreState {
        return MoreState(url: action.url)
    }
}
