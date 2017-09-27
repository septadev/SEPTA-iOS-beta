//
//  NextToArriveViewModel+RouteCell.swift
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
    // MARK: -  configure routes

    func configureSelectRouteDisplayModel() -> NextToArriveRowDisplayModel {

        let cellModel: CellModel
        if transitMode == .rail {
            cellModel = configureRouteForRail()
        } else if let route = scheduleRequest?.selectedRoute {
            cellModel = configureRouteForNonRail_RouteDefined(route: route)
        } else {
            cellModel = configureRouteForNonRail_NoRoute()
        }
        return cellModel
    }

    func configureRouteForRail() -> NextToArriveRowDisplayModel {
        return CellModel(text: SeptaString.NoRouteNeeded, cellId: "NoRouteNeeded")
    }

    func configureRouteForNonRail_NoRoute() -> NextToArriveRowDisplayModel {
        return CellModel(
            text: transitMode.selectRoutePlaceholderText(),
            cellId: "singleStringCell",
            shouldFillCell: true,
            isSelectable: true,
            targetController: .routesViewController,
            showSearchIcon: false,
            fontWeight: UIFont.Weight.regular,
            searchIconName: "selectRouteAccessory")
    }

    func configureRouteForNonRail_RouteDefined(route: Route) -> NextToArriveRowDisplayModel {
        return CellModel(
            text: route.routeLongName,
            cellId: "singleStringCell",
            shouldFillCell: true,
            isSelectable: true,
            targetController: .routesViewController,
            pillColor: Route.colorForRoute(route, transitMode: transitMode),
            showSearchIcon: false,
            fontWeight: UIFont.Weight.medium,
            searchIconName: "selectRouteAccessory")
    }
}
