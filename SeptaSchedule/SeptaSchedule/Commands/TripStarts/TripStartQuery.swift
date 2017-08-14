
import Foundation

public struct TripStartQuery: SQLQueryProtocol {

    let transitMode: TransitMode
    let route: Route
    let fileName = "tripStartBus"

    var sqlBindings: [[String]] {
        return [[":route_id", route.routeId]]
    }
}
