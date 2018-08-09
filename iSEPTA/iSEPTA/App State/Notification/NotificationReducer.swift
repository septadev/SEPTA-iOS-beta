//
//  NotificationReducer.swift
//  iSEPTA
//
//  Created by Mike Mannix on 8/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct NotificationReducer {
    static func main(action: Action, state: NotificationState?) -> NotificationState {
        if let state = state {
            guard let action = action as? NotificationAction else { return state }
            return reduceNotificationAction(action: action, state: state)
        } else {
            return NotificationState()
        }
    }

    static func reduceNotificationAction(action _: NotificationAction, state: NotificationState) -> NotificationState {
//        var notificationState = state
//        switch action {
//        case let action as DelayNotificationTapped:
//            notificationState.payload = action.payload
//        default:
//            break
//        }
        return state
    }
}
