// Septa. 2017

import Foundation

public struct TransitRoute: Codable {
    public let routeId: String
    public let routeType: String
    public let routeName: String
    
    public init(routeId: String, routeType: String, routeName: String) {
        self.routeId = routeId
        self.routeType = routeType
        self.routeName = routeName
    }
    
    public func mode() -> TransitMode {
        switch routeType {
        case "0":
            return .trolley
        default:
            return .bus
        }
    }
    
    public var hashValue: Int {
        return routeId.hashValue
    }
    
    enum CodingKeys: String, CodingKey {
        case routeId
        case routeType
        case routeName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decode(String.self, forKey: .routeId)
        routeType = try container.decode(String.self, forKey: .routeType)
        routeName = try container.decode(String.self, forKey: .routeName)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(routeId, forKey: .routeId)
        try container.encode(routeType, forKey: .routeType)
        try container.encode(routeName, forKey: .routeName)
    }
}

extension TransitRoute: Hashable {
}

extension TransitRoute: Equatable {}
public func == (lhs: TransitRoute, rhs: TransitRoute) -> Bool {
    var areEqual = true
    
    if lhs.routeId == rhs.routeId {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }
    
    if lhs.routeType == rhs.routeType {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }
    
    if lhs.routeName == rhs.routeName {
        areEqual = true
    } else {
        areEqual = false
    }
    guard areEqual else { return false }
    
    return areEqual
}
