// SEPTA.org, created on 8/1/17.

import Foundation
import SeptaSchedule

struct RouteStops {
    let startStop: Stop?
    let destinationStop: Stop?

    var isComplete: Bool {
        return startStop != nil && destinationStop != nil
    }
}
