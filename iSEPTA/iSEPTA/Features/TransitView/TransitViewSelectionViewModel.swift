//
//  TransitViewSelectionViewModel.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/9/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

class TransitViewSelectionViewModel: StoreSubscriber {
    
    typealias StoreSubscriberStateType = [TransitRoute]
    
    weak var delegate: UpdateableFromViewModel?
    var selectedRoutes: [TransitRoute]?
    
    init(delegate: UpdateableFromViewModel) {
        self.delegate = delegate
        subscribe()
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.transitViewState.selectedRoutes
            }
        }
    }
    
    func newState(state: StoreSubscriberStateType) {
        selectedRoutes = state
        delegate?.viewModelUpdated()
    }
    
    func cellFor(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let routes = selectedRoutes else { return UITableViewCell() }
        let row = indexPath.section
        
        if row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonViewCell", for: indexPath) as! ButtonViewCell
            cell.buttonText = "View Map"
            cell.enabled = routes.count > 0
            return cell
        }
        
        if row < routes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeSelectedCell", for: indexPath) as! RouteSelectedTableViewCell
            let route = routes[row]
            cell.routeIdLabel.text = "\(route.routeId):"
            cell.routeShortNameLabel.text = route.routeLongName
            cell.pillView.backgroundColor = Route.colorForRouteId(route.routeId, transitMode: route.mode())
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "singleStringCell", for: indexPath) as! SingleStringCell
            cell.setEnabled(row == routes.count)
            return cell
        }
    }
    
    func canSelectRow(row: Int) -> Bool {
        guard let routes = selectedRoutes else { return false }
        return row <= routes.count
    }
}
