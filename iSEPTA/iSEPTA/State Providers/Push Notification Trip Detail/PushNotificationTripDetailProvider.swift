//
//  PushNotificationTripDetailProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/7/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

class PushNotificationTripDetailProvider: PushNotificationTripDetailState_TripIdWatcherDelegate {
    let watcher: PushNotificationTripDetailState_TripIdWatcher
    let request: PushNotificationTripDetailRequest

    var timer: Timer? {
        willSet (newTimer){
            if let oldTimer = self.timer {
                oldTimer.invalidate()
            }
        }
    }
    
    var tripId: String? {
        didSet {
            if let tripId = tripId {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: timerFired)
                requestData(tripId: tripId)
            } else {
                timer = nil
            }
        }
    }

    static let sharedInstance = PushNotificationTripDetailProvider()

    private init() {
        watcher = PushNotificationTripDetailState_TripIdWatcher()
        request = PushNotificationTripDetailRequest()
        watcher.delegate = self
    }

    func pushNotificationTripDetailState_TripIdUpdated(tripId: String?) {
        self.tripId = tripId
    }

    func timerFired(timer _: Timer) {
        guard let tripId = tripId else { return }
        requestData(tripId: tripId)
    }

    func requestData(tripId: String) {
        updateStatus(status: PushNotificationTripDetailStatus.dataLoading)
        request.sendRequestRealTimeTripsDetails(tripId: tripId, completion: mapResponse)
    }

    func mapResponse(data: Data?, statusCode: Int) {
        if let data = data {
            do {
                let tripDetailData = try PushNotificationTripDetailMapper.mapData(data: data)
                updateState(tripDetailData: tripDetailData)
            } catch PushNotificationTripDetailMapperError.badJsonFormat {
                updateStatus(status: PushNotificationTripDetailStatus.jsonParsingError)
            } catch PushNotificationTripDetailMapperError.missingDetailsProbablyExpired {
                updateStatus(status: PushNotificationTripDetailStatus.noResultsReturned)
            } catch {
                updateStatus(status: PushNotificationTripDetailStatus.jsonParsingError)
            }
        } else {
            updateStatus(status: PushNotificationTripDetailStatus.networkError)
        }
    }

    func updateStatus(status: PushNotificationTripDetailStatus) {
        store.dispatch(UpdatePushNotificationTripDetailStatus(status: status))
    }

    func updateState(tripDetailData: PushNotificationTripDetailData) {
        store.dispatch(UpdatePushNotificationTripDetailData(pushNotificationTripDetailData: tripDetailData))
    }
}
