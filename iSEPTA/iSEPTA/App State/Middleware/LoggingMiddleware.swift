//
//  LoggingMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/18/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import Crashlytics

let loggingMiddleware: Middleware<Any> = { _, _ in { next in
    return { action in
        if let action = action as? SeptaAction {
            print(action.description)
            Answers.logCustomEvent(withName: action.description, customAttributes: nil)
        }

        return next(action)
    }
}
}
