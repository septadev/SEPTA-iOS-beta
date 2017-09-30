//
//  ContactViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class ContactViewModel {

    func customerServiceOptions() -> [ContactPoint] {
        return [phoneCall, TTYCall, comment, chat]
    }

    func customerSocialMediaOptions() -> [ContactPoint] {
        return [twitter, facebook]
    }

    private let phoneCall: ContactPoint = {
        ContactPoint(
            imageName: "callIcon",
            septaConnection: .phone,
            showChevron: false)
    }()

    private let TTYCall: ContactPoint = {
        ContactPoint(
            imageName: "TTYIcon",
            septaConnection: .tdd,
            showChevron: false)
    }()

    private let comment: ContactPoint = {
        ContactPoint(
            imageName: "commentIcon",
            septaConnection: .comment,
            showChevron: true)
    }()

    private let chat: ContactPoint = {
        ContactPoint(
            imageName: "chatIcon",
            septaConnection: .chat,
            showChevron: true)
    }()

    private let facebook: ContactPoint = {
        ContactPoint(
            imageName: "facebookIcon",
            septaConnection: .facebook,
            showChevron: true)
    }()

    private let twitter: ContactPoint = {
        ContactPoint(
            imageName: "twitterIcon",
            septaConnection: .twitter,
            showChevron: true)
    }()
}
