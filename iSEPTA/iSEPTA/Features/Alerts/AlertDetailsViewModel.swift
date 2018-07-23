//
//  AlertDetailsViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

class AlertDetailsViewModel {
    static func hasGenericMessage(alertDetails: [AlertDetails_Alert]) -> Bool {
        let messages = alertDetails.map({ $0.message }) + alertDetails.map({ $0.advisory_message })
        let nonNilMessages = messages.flatMap({ $0 }).filter { $0.count > 0 }
        return nonNilMessages.count > 0
    }

    static func renderMessage(alertDetails: [AlertDetails_Alert], filter: ((AlertDetails_Alert) -> String?)) -> NSAttributedString? {
        let message: String = alertDetails.filter({
            guard let message = filter($0) else { return false }
            return message.count > 0
        }).map({ filter($0)! }).joined(separator: "")

        if message.count > 0 {
            return message.htmlAttributedString
        } else {
            return nil
        }
    }
}
