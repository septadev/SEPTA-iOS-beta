//
//  SEPTAConnectionMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/30/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

let septaConnectionMiddleware: Middleware<Any> = { _, _ in { next in
    return { action in
        if let action = action as? SeptaAction {
            if let action = action as? SeptaConnectionAction {
                SeptaConnectionMiddleware.generateActions(action: action)
            }
        }
        return next(action)
    }
}
}

class SeptaConnectionMiddleware {

    static func generateActions(action: SeptaConnectionAction) {
        switch action {
        case let action as MakeSeptaConnection:
            generateActionsToMakeSeptaConnection(action: action)

        default:
            break
        }
    }

    static func generateActionsToMakeSeptaConnection(action: MakeSeptaConnection) {

        let septaConnection = action.septaConnection

        if septaConnection.urlConnectionMode() == .withinApp {
            let updateAction = UpdateSeptaConnection(septaConnection: septaConnection)
            store.dispatch(updateAction)

            let pushAction = PushViewController(viewController: .webViewController, description: "Showing Fares Web View")
            store.dispatch(pushAction)
        } else {
            UIApplication.shared.openURL(septaConnection.url())
        }
    }
}
