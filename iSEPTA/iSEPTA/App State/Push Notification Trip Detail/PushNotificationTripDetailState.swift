//
//  PushNotificationTripDetailState.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

struct PushNotificationTripDetailState: Equatable, Encodable {
    var pushNotificationTripDetailUpdateStatus: PushNotificationTripDetailStatus = .idle
    var pushNotificationTripDetailData: PushNotificationTripDetailData?
    var delayNotification: SeptaDelayNotification?
    var tripId: String?
    var routeId: String?
    var results: Int? = nil

    var shouldDisplayPushNotificationTripDetail: Bool {
//        guard let results = results else { return false }
//        return tripId != nil && results > 0 && pushNotificationTripDetailUpdateStatus == .dataLoadedSuccessfully

        guard let latitude = pushNotificationTripDetailData?.latitude else { return false }
        return latitude != 0.0
    }

    var shouldDisplayExpiredNotification: Bool {
        let errorStatusCodes: [PushNotificationTripDetailStatus] =  [.noResultsReturned]
        return (errorStatusCodes.contains(pushNotificationTripDetailUpdateStatus))
    }

     var shouldDisplayNetWorkError: Bool {
        let errorStatusCodes: [PushNotificationTripDetailStatus] =  [.jsonParsingError, .networkError]
        return (errorStatusCodes.contains(pushNotificationTripDetailUpdateStatus))
    }
}

