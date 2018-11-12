//
//  PushNotificationTripDetailUpdateStatus.swift
//  iSEPTA
//
//  Created by Mark Broski on 11/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum PushNotificationTripDetailStatus: String, Equatable, Encodable {
    case idle
    case dataLoadRequested
    case dataLoading
    case dataLoadedSuccessfully
    case dataMappedSuccessfully
    case networkError
    case jsonParsingError
    case noResultsReturned
}

enum PushNotificationTripDetailUpdateStatusError: Error {
    case noResultsReturned
}
