//
//  PushNotificationTripDetailState.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

struct PushNotificationTripDetailState: Equatable {
    var pushNotificationTripDetailUpdateStatus: PushNotificationTripDetailStatus = .idle
    var pushNotificationTripDetailData: PushNotificationTripDetailData?
    var delayNotification: SeptaDelayNotification?
    var tripId: String?
    var routeId: String?
    var results: Int? = nil

    var readyToPresent: Bool {
        guard let results = results else { return false }
        return tripId != nil && results > 0 && pushNotificationTripDetailUpdateStatus == .dataLoadedSuccessfully
    }

    var shouldDisplayErrorMessageInsteadOfPresenting: Bool {
        return tripId != nil && pushNotificationTripDetailUpdateStatus == .noResultsReturned
    }
}

