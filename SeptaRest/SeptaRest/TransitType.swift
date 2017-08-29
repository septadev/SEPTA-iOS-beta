//
//  TransitType.swift
//  Pods
//
//  Created by John Neyer on 8/25/17.
//
//

import Foundation

public enum TransitType {

    case RAIL
    case BUS
    case TROLLEY
    case SUBWAY
    case NHSL

    public var value: String {
        let type: String = {
            switch self {
            case .RAIL:
                return "RAIL"
            case .BUS:
                return "BUS"
            case .TROLLEY:
                return "TROLLEY"
            case .SUBWAY:
                return "SUBWAY"
            case .NHSL:
                return "NHSL"
            }
        }()
        return type
    }
}
