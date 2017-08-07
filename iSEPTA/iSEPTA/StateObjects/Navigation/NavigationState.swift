// Septa. 2017

import Foundation
import UIKit
import ReSwift

struct NavigationState {

    var selectedFeature: Feature
    var activeFeature: Feature

    public init(selectedFeature: Feature, activeFeature: Feature) {
        self.selectedFeature = selectedFeature
        self.activeFeature = activeFeature
    }
}

extension NavigationState: Equatable {}
func ==(lhs: NavigationState, rhs: NavigationState) -> Bool {
    var areEqual = true

    if lhs.selectedFeature == rhs.selectedFeature {
        areEqual = true
    } else {
        return false
    }

    if lhs.activeFeature == rhs.activeFeature {
        areEqual = true
    } else {
        return false
    }
    return areEqual
}
