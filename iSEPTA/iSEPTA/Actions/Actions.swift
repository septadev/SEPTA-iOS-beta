// Septa. 2017

import Foundation
import ReSwift

struct SwitchFeature: Action {

    let selectedFeature: Feature
}

struct SwitchFeatureCompleted: Action {

    let activeFeature: Feature
}
