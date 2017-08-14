// Septa. 2017

import Foundation

public struct Route: Codable {
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

    enum CodingKeys: String, CodingKey {
        case routeId = "route_id"
        case routeShortName = "route_short_name"
        case routeLongName = "route_long_name"
        case routeDirectionCode = "dircode"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decode(String.self, forKey: .routeId)
        routeShortName = try container.decode(String.self, forKey: .routeShortName)
        routeLongName = try container.decode(String.self, forKey: .routeLongName)
        let dirCode = try container.decode(String.self, forKey: .routeDirectionCode)
        if let dirCodeInt = Int(dirCode), let routeDirectionCode = RouteDirectionCode(rawValue: dirCodeInt) {
            self.routeDirectionCode = routeDirectionCode
        } else {
            routeDirectionCode = RouteDirectionCode.inbound
        }
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
