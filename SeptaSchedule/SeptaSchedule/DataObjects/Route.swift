// Septa. 2017

import Foundation

public struct Route: Codable {
    public let routeId: String
    public let routeShortName: String
    public let routeLongName: String

    public init(routeId: String, routeShortName: String, routeLongName: String) {
        self.routeId = routeId
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
    }

    enum CodingKeys: String, CodingKey {
        case routeId = "route_id"
        case routeShortName = "route_short_name"
        case routeLongName = "route_long_name"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            routeId = try container.decode(String.self, forKey: .routeId)
        } catch {
            let intRouteId = try container.decode(Int.self, forKey: .routeId)
            routeId = String(intRouteId)
        }
        routeShortName = try container.decode(String.self, forKey: .routeShortName)
        routeLongName = try container.decode(String.self, forKey: .routeLongName)
    }
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

    return areEqual
}
