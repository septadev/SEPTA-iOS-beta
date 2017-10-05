//
//  GenericAlertDetailProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

class GenericAlertDetailProvider {

    static let sharedInstance = GenericAlertDetailProvider()
    let genericRouteId = "generic"
    var timer: Timer?

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    private init() {
        timer = Timer.scheduledTimer(timeInterval: 60 * 5, target: self, selector: #selector(timerFired(timer:)), userInfo: nil, repeats: true)
    }

    @objc func timerFired(timer _: Timer) {
        getGenericAlert()
    }

    func getGenericAlert() {
        client.getAlertDetails(routeName: genericRouteId).then { alertDetails -> Void in
            if let genericAlertDetails = alertDetails?.alerts {
                let action = GenericAlertDetailsLoaded(genericAlertDetails: genericAlertDetails)
                store.dispatch(action)
            }
        }.catch { err in
            print(err)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
