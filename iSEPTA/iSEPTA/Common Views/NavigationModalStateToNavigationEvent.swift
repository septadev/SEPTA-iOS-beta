//
//  NavigationModalStateToNavigationEvent.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/21/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
enum ModalEventNeeded {
    case noActionNeeded
    case presentModal(ViewController)
    case dismissModal
    case dismissThenPresent(ViewController)
}

class NavigationModalStateToNavigationEvent {
    let currentModal: ViewController?
    let newModal: ViewController?

    init(currentModal: ViewController?, newModal: ViewController?) {
        self.currentModal = currentModal
        self.newModal = newModal
    }

    func determineNecessaryStateAction() -> ModalEventNeeded {
        switch (currentModal, newModal) {
        case (.some, nil):
            return .dismissModal
        case (nil, let .some(newModal)):
            return .presentModal(newModal)
        case (nil, nil):
            return .noActionNeeded
        case let (.some(currentModal), .some(newModal)) where currentModal == newModal:
            return .noActionNeeded
        case let (.some(currentModal), .some(newModal)) where currentModal != newModal:
            return .dismissThenPresent(newModal)
        default:
            return .noActionNeeded
        }
    }
}
