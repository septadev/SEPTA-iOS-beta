// Septa. 2017

import Foundation

public enum SQLQuery {
    case busStart(routeId: String, scheduleType: ScheduleType)
    case busEnd(routeId: String, scheduleType: ScheduleType, startStopId: Int)
    case busTrip(routeId: String, scheduleType: ScheduleType, startStopId: Int, endStopId: Int)
    case busRoute(routeType: RouteType)

    var sqlBindings: [[String]] {
        switch self {
        case let .busStart(routeId, scheduleType):
            return [[":route_id", routeId], [":service_id", String(scheduleType.rawValue)]]
        case let .busEnd(routeId, scheduleType, startStopId):
            return [[":route_id", routeId], [":service_id", String(scheduleType.rawValue)], [":start_stop_id", String(startStopId)]]
        case let .busTrip(routeId, scheduleType, startStopId, endStopId):
            return [[":route_id", routeId], [":service_id", String(scheduleType.rawValue)], [":start_stop_id", String(startStopId)], [":end_stop_id", String(endStopId)]]
        case let .busRoute(routeType):
            return [[":route_type", String(routeType.rawValue)]]
        }
    }

    var fileName: String {
        switch self {
        case .busStart: return "busStart"
        case .busEnd: return "busEnd"
        case .busTrip: return "busTrip"
        case .busRoute: return "busRoute"
        }
    }
}
