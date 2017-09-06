//
//  NextToArriveViewModel+StartCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

extension NextToArriveViewModel {

    func configureSelectStartDisplayModel() -> NextToArriveRowDisplayModel {
        let cellModel: CellModel
        if let route = scheduleRequest?.selectedRoute, let start = scheduleRequest?.selectedStart {
            cellModel = configureSelectedStart_RouteDefined_StartDefined(route: route, start: start)
        } else if let route = scheduleRequest?.selectedRoute {
            cellModel = configureSelectedStart_RouteDefined_NoStart(route: route)
        } else {
            cellModel = configureSelectedStart_NoRoute()
        }
        return cellModel
    }

    func configureSelectedStart_NoRoute() -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.startingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: false,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedStart_RouteDefined_NoStart(route _: Route) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.startingStopName(),
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }

    func configureSelectedStart_RouteDefined_StartDefined(route _: Route, start: Stop) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: start.stopName,
            cellId: "singleStringCell",
            shouldFillCell: false,
            isSelectable: true,
            targetController: .selectStopController,
            showSearchIcon: true,
            fontWeight: UIFont.Weight.regular)
    }
}
