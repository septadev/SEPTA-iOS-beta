// Septa. 2017

import Foundation
import ReSwift

protocol NavigationAction: Action {}

struct SwitchFeature: NavigationAction {

    let selectedFeature: FeatureNavController
}

struct SwitchFeatureCompleted: NavigationAction {

    let activeFeature: FeatureNavController
}
