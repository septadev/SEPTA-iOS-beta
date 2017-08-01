// SEPTA.org, created on 7/31/17.

import Foundation

enum SQLQuery {
    case busStart(routeId: Int, scheduleType: ScheduleType)

    var sqlBindings: [[String]] {
        switch self {
        case let .busStart(routeId, scheduleType):
            return [[":route_id", String(routeId)], [":service_id", String(scheduleType.rawValue)]]
        }
    }

    var fileName: String {
        switch self {
        case .busStart: return "busStart"
        }
    }
}
