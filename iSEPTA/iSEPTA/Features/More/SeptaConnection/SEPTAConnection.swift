//
//  SeptaUrl.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum SEPTAConnection {
    case map
    case fares
    case septaKey
    case passPerks
    case phone
    case tddTTY
    case twitter
    case facebook
    case comment
    case chat

    func url() -> URL! {
        guard let urls = SEPTAUrlProvider.sharedInstance.urls else { return nil }
        var urlString: String?
        switch self {
        case .map: urlString = urls.map
        case .fares: urlString = urls.fares
        case .septaKey: urlString = urls.septaKey
        case .passPerks: urlString = urls.passPerks
        case .phone: urlString = urls.phone
        case .tddTTY: urlString = urls.tdd
        case .twitter: urlString = urls.twitter
        case .facebook: urlString = urls.facebook
        case .comment: urlString = urls.comment
        case .chat: urlString = urls.chat
        }
        guard let string = urlString else { return nil }
        return URL(string: string)
    }

    func title() -> String {
        switch self {
        case .map: return "SEPTA Map"
        case .fares: return "More Fares Information"
        case .septaKey: return "SEPTA Key"
        case .passPerks: return "PASS Perks"
        case .phone: return "Call"
        case .tddTTY: return "TDD/TTY"
        case .twitter: return "@SEPTA_SOCIAL"
        case .facebook: return "SEPTA Facebook"
        case .comment: return "Send us a comment"
        case .chat: return "Live Chat"
        }
    }

    func formattedLink() -> String? {
        switch self {

        case .phone: return "(215)-580-7800"
        case .tddTTY: return "(215)-580-7853"
        default: return nil
        }
    }

    func urlConnectionMode() -> URLConnectionMode {
        switch self {
        case .phone, .tddTTY: return .outsideApp
        default: return .withinApp
        }
    }
}
