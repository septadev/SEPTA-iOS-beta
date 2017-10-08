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
        let message = renderMessage(alertDetails: alertDetails) { return $0.message }
        return message != nil
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
