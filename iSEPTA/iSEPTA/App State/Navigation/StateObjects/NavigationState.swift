// Septa. 2017

import Foundation
import UIKit
import ReSwift

struct NavigationState: Codable {

    let selectedFeature: FeatureNavController?
    let activeFeature: FeatureNavController?

    init(selectedFeature: FeatureNavController? = nil, activeFeature: FeatureNavController? = nil) {
        self.selectedFeature = selectedFeature
        self.activeFeature = activeFeature
    }
}

extension NavigationState: Equatable {}
func ==(lhs: NavigationState, rhs: NavigationState) -> Bool {
    var areEqual = true

    switch (lhs.selectedFeature, rhs.selectedFeature) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.selectedFeature! == rhs.selectedFeature!
    default:
        return false
    }

    switch (lhs.activeFeature, rhs.activeFeature) {
    case (.none, .none):
        areEqual = true
    case (.some, .some):
        areEqual = lhs.activeFeature! == rhs.activeFeature!
    default:
        return false
    }
    return areEqual
}
