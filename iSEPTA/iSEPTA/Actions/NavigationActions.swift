// Septa. 2017

import Foundation
import ReSwift

protocol NavigationAction: Action {}

struct SwitchFeature: NavigationAction {

    let selectedFeature: Feature
}

struct SwitchFeatureCompleted: NavigationAction {

    let activeFeature: Feature
}
