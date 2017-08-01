// SEPTA.org, created on 8/1/17.

import Foundation

class GeoCompare {

    class func point(_ p1: Double, _ p2: Double) -> Bool {
        return abs(abs(p1) - abs(p2)) < 0.000001
    }

}
