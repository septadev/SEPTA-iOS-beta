//
//  NextToArriveViewModel+StopCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

extension NextToArriveViewModel {

    func configureSelectEndDisplayModel() -> NextToArriveRowDisplayModel {
        let cellModel: CellModel
        if let route = scheduleRequest?.selectedRoute, let start = scheduleRequest?.selectedStart, let end = scheduleRequest?.selectedEnd {
            cellModel = configureSelectedEnd_RouteDefined_StartDefined_StopDefined(route: route, start: start, end: end)
        } else if let route = scheduleRequest?.selectedRoute, let start = scheduleRequest?.selectedStart {
            cellModel = configureSelectedEnd_RouteDefined_StartDefined_NoStop(route: route, start: start)
        } else if let route = scheduleRequest?.selectedRoute {
            cellModel = configureSelectedEnd_RouteDefined_NoStart(route: route)
        } else {
            cellModel = configureSelectedEnd_NoRoute()
        }
        return cellModel
    }

    func configureSelectedEnd_NoRoute() -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.endingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: true,
            isSelectable: false,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedEnd_RouteDefined_NoStart(route _: Route) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.endingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: true,
            isSelectable: false,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedEnd_RouteDefined_StartDefined_NoStop(route _: Route, start _: Stop) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.endingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: true,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedEnd_RouteDefined_StartDefined_StopDefined(route _: Route, start _: Stop, end: Stop) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: end.stopName,
            cellId: "singleStringCell",
            shouldFillCell: true,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.medium)
    }
}
