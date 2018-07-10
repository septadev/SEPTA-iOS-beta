// Septa. 2017

import Foundation

public struct TransitRoute: Codable {
    public let routeId: String
    public let routeType: String
    public let routeShortName: String
    public let routeLongName: String
    public let routeDirectionCode: RouteDirectionCode
    
    public init(routeId: String, routeType: String, routeShortName: String, routeLongName: String, routeDirectionCode: RouteDirectionCode) {
        self.routeId = routeId
        self.routeType = routeType
        self.routeShortName = routeShortName
        self.routeLongName = routeLongName
        self.routeDirectionCode = routeDirectionCode
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
        return routeId.hashValue * routeDirectionCode.rawValue.hashValue
    }
    
    enum CodingKeys: String, CodingKey {
        case routeId
        case routeType
        case routeShortName
        case routeLongName
        case routeDirectionCode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container
        routeId = try container.decode(String.self, forKey: .routeId)
        routeType = try container.decode(String.self, forKey: .routeType)
        routeShortName = try container.decode(String.self, forKey: .routeShortName)
        routeLongName = try container.decode(String.self, forKey: .routeLongName)
        let routeDirectionCodeInt = try container.decode(Int.self, forKey: .routeDirectionCode)
        if let routeDirectionCode = RouteDirectionCode(rawValue: routeDirectionCodeInt) {
            self.routeDirectionCode = routeDirectionCode
        } else {
            throw CodableError.decodingKeyNotFound
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(routeId, forKey: .routeId)
        try container.encode(routeType, forKey: .routeType)
        try container.encode(routeShortName, forKey: .routeShortName)
        try container.encode(routeLongName, forKey: .routeLongName)
        try container.encode(routeDirectionCode.rawValue, forKey: .routeDirectionCode)
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
