//
//  RouteDrawable.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

protocol RouteDrawable: AnyObject {
    func drawRoute(routeId: String)
    func drawTrip(scheduleRequest: ScheduleRequest)
    func drawVehicleLocations(_ vehicleLocations: [VehicleLocation])
}
