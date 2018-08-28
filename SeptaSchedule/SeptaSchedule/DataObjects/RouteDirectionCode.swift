//
//  DirectionCode.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

public enum RouteDirectionCode: Int, Equatable {
    case inbound = 0
    case outbound = 1

    public static func fromNetwork(_ string: String) -> RouteDirectionCode? {
        if string == "Outbound" {
            return .outbound
        } else if string == "Inbound" {
            return .inbound

        } else {
            return nil
        }
    }
}
