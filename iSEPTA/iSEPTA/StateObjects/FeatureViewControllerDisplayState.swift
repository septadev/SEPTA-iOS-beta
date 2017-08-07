//
//  FeatureViewControllerDisplayRequest.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct FeatureViewControllerDisplayState {
    let requestedViewController: FeatureViewController
    let activeViewController: FeatureViewController

    let embeddedViews: [EmbeddedView: FeatureViewControllerDisplayState]?

    public init(requestedViewController: FeatureViewController, activeViewController: FeatureViewController, embeddedViews: [EmbeddedView: FeatureViewControllerDisplayState]?) {
        self.requestedViewController = requestedViewController
        self.activeViewController = activeViewController
        self.embeddedViews = embeddedViews
    }
}

extension FeatureViewControllerDisplayState: Equatable {}
func ==(lhs: FeatureViewControllerDisplayState, rhs: FeatureViewControllerDisplayState) -> Bool {
    var areEqual = true

    if lhs.requestedViewController == rhs.requestedViewController {
        areEqual = true
    } else {
        return false
    }

    if lhs.activeViewController == rhs.activeViewController {
        areEqual = true
    } else {
        return false
    }

    switch (lhs.embeddedViews, rhs.embeddedViews) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.embeddedViews! == rhs.embeddedViews!
    default:
        return false
    }
    return areEqual
}
