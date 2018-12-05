//
//  MainNavigationControllerAlertManager.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/16/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift


// TODO: JJ Alert Queue
class MainNavigationControllerAlertManager: StoreSubscriber {
    typealias StoreSubscriberStateType = AppAlert?

    static let sharedInstance = MainNavigationControllerAlertManager()

    private var alertsToDisplay = [AppAlert: (()->())]()

    public func addAlertToDisplay(appAlert: AppAlert, block: @escaping (()->())){
        alertsToDisplay[appAlert] = block
        store.dispatch(AddAlertToDisplay(appAlert: appAlert))
    }
    
    public func removeDisplayedAlert(appAlert: AppAlert) {
        alertsToDisplay.removeValue(forKey: appAlert)
        store.dispatch(CurrentAppAlertDismissed())
    }
    
    public func hasAlertsInQueue() -> Bool {
        if alertsToDisplay.count > 0 {
            return true
        }
        return false
    }
    
    public func clearAlertQueue() {
        alertsToDisplay.removeAll()
    }

    private init(){
        //subscribe()
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.nextAlertToDisplay }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        guard let appAlert = state,
            let block = alertsToDisplay[appAlert]
        else { return }
        block()
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        store.unsubscribe(self)
    }
}
