// Septa. 2017

import Foundation

struct FeatureViewControllerDisplayState {
    let requestedViewController: FeatureViewController?
    let activeViewController: FeatureViewController?
    let embeddedViews: [EmbeddedView: FeatureViewControllerDisplayState]?

    init(requestedViewController: FeatureViewController? = nil, activeViewController: FeatureViewController? = nil, embeddedViews: [EmbeddedView: FeatureViewControllerDisplayState]? = nil) {
        self.requestedViewController = requestedViewController
        self.activeViewController = activeViewController
        self.embeddedViews = embeddedViews
    }
}

extension FeatureViewControllerDisplayState: Equatable {}
func ==(lhs: FeatureViewControllerDisplayState, rhs: FeatureViewControllerDisplayState) -> Bool {
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
