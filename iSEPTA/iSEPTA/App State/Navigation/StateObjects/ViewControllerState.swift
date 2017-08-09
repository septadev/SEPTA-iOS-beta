// Septa. 2017

import Foundation

struct ViewControllerState: Codable {
    let requestedViewController: FeatureViewController?
    let activeViewController: FeatureViewController?
    let embeddedViews: [EmbeddedView: ViewControllerState]?

    init(requestedViewController: FeatureViewController? = nil, activeViewController: FeatureViewController? = nil, embeddedViews: [EmbeddedView: ViewControllerState]? = nil) {
        self.requestedViewController = requestedViewController
        self.activeViewController = activeViewController
        self.embeddedViews = embeddedViews
    }
}

extension ViewControllerState: Equatable {}
func ==(lhs: ViewControllerState, rhs: ViewControllerState) -> Bool {
    var areEqual = true

    switch (lhs.requestedViewController, rhs.requestedViewController) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.requestedViewController! == rhs.requestedViewController!
    default:
        return false
    }

    switch (lhs.activeViewController, rhs.activeViewController) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.activeViewController! == rhs.activeViewController!
    default:
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
