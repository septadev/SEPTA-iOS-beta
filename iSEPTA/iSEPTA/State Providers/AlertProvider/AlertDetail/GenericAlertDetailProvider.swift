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
    let genericRouteId = SeptaNetwork.sharedInstance.genericAlertName
    let appAlertName = SeptaNetwork.sharedInstance.appAlertName

    var timer: Timer?

    let client = SEPTAApiClient.defaultClient(url: SeptaNetwork.sharedInstance.url, apiKey: SeptaNetwork.sharedInstance.apiKey)

    private init() {
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(timerFired(timer:)), userInfo: nil, repeats: true)
        getGenericAlert()
    }

    @objc func timerFired(timer _: Timer) {
        getGenericAlert()
        getAppAlerts()
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

    func getAppAlerts() {
        client.getAlertDetails(routeName: appAlertName).then { alertDetails -> Void in
            if let appAlertDetails = alertDetails?.alerts {
                let action = AppAlertDetailsLoaded(appAlertDetails: appAlertDetails)
                store.dispatch(action)
            }
        }.catch { err in
            let action = AppAlertDetailsLoaded(appAlertDetails: [AlertDetails_Alert]())
            store.dispatch(action)
            print(err)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
