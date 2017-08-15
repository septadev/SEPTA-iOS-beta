// Septa. 2017

import Foundation

public struct Route {
    public let routeId: String
    public let routeShortName: String
    public let routeLongName: String
    public let routeDirectionCode: RouteDirectionCode

    init(routeId: String, routeShortName: String, routeLongName: String, routeDirectionCode: RouteDirectionCode) {
        self.routeId = routeId
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
        self.routeDirectionCode = routeDirectionCode
    }

    public var hashValue: Int {
        return routeId.hashValue * routeDirectionCode.rawValue.hashValue
    }
}

extension Route: Hashable {
}

extension Route: Equatable {}
public func ==(lhs: Route, rhs: Route) -> Bool {
    var areEqual = true

    if lhs.routeId == rhs.routeId {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.routeShortName == rhs.routeShortName {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.routeLongName == rhs.routeLongName {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    if lhs.routeDirectionCode == rhs.routeDirectionCode {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }

    return areEqual
}
