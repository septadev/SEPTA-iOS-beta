// Septa. 2017

import Foundation

extension TransitMode: SQLQueryProtocol {

    var sqlBindings: [[String]] {

        switch self {
        case .bus:
            return [[":route_id", " R.route_id not in ( 'BSO', 'BSL', 'MFL' ) "], [":route_type", " R.route_type = 3"]]
        case .nhsl:
            return [[":route_id", "  R.route_id = 'NHSL'"], [":route_type", " 1 = 1 "]]
        case .trolley:
            return [[":route_id", " R.route_id != 'NHSL' "], [":route_type", "  R.route_type = 0 "]]
        case .subway:
            return [[":route_id", " R.route_id in ( 'BSO', 'BSL', 'MFL' ) "], [":route_type", "1 = 1 "]]
        case .rail:
            return [[String]]()
        }
    }

    var fileName: String {
        switch self {
        case .bus: return "busRoute"
        case .rail: return "railRoute"
        case .subway: return "busRoute"
        case .trolley: return "busRoute"
        case .nhsl: return "busRoute"
        }
    }
}
