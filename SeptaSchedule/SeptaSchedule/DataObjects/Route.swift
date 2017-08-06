// Septa. 2017

import Foundation

public struct Route {
    public let routeId: String
    public let routeShortName: String
    public let routeLongName: String

    public init(routeId: String, routeShortName: String, routeLongName: String) {
        self.routeId = routeId
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
    }
}

extension Route: Equatable {}
public func ==(lhs: Route, rhs: Route) -> Bool {
    return lhs.routeId == rhs.routeId &&
        lhs.routeShortName == rhs.routeShortName &&
        lhs.routeLongName == rhs.routeLongName
}
