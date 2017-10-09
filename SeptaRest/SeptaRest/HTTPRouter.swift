//
//  HTTPRouter.swift
//  Pods
//
//  Created by John Neyer on 8/24/17.
//
//

import Foundation

public enum HTTPRouter {

    static var baseURLString = ""

    case Alerts
    case AlertDetails
    case Arrivals
    case RealTimeArrivals
    case RealTimeArrivalDetail
    case TransitRoutes
    case TrainRoutes

    case CheckSessionStatus

    public var URLString: String {
        let path: String = {
            switch self {
            case .Alerts:
                return "alerts"
            case .AlertDetails:
                return "alert-details"
            case .Arrivals:
                return "arrivals"
            case .RealTimeArrivals:
                return "realtimearrivals"
            case .RealTimeArrivalDetail:
                return "realtimearrivals/details"
            case .TransitRoutes:
                return "transitroutes"
            case .TrainRoutes:
                return "trainroutes"
            default:
                return ""
            }
        }()

        if HTTPRouter.baseURLString.characters.last != "/" {
            HTTPRouter.baseURLString = HTTPRouter.baseURLString + "/"
        }

        return HTTPRouter.baseURLString + path
    }
}
