//
//  TransitViewRoutesViewModel.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/6/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule
import ReSwift

class TransitViewRoutesViewModel: NSObject, StoreSubscriber, UITextFieldDelegate {

    typealias StoreSubscriberStateType = TransitViewState

    var updateableFromViewModelController: UpdateableFromViewModel?
    
    var slotBeingChanged: TransitViewRouteSlot?
    
    var allRoutes: [TransitRoute]? {
        didSet {
            guard let allRoutes = allRoutes else { return }
            allFilterableRoutes = allRoutes.map {
                FilterableTransitRoute(route: $0)
            }
        }
    }
    
    fileprivate var allFilterableRoutes: [FilterableTransitRoute]? {
        didSet {
            filteredRoutes = allFilterableRoutes
        }
    }
    
    var filteredRoutes: [FilterableTransitRoute]? {
        didSet {
            guard let filteredRoutes = filteredRoutes else { return }
            self.filteredRoutes = filteredRoutes.sorted {
                $0.sortString < $1.sortString
            }
            updateableFromViewModelController?.viewModelUpdated()
        }
    }
    
    override init() {
        super.init()
        subscribe()
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.transitViewState }.skipRepeats { $0 == $1 }
        }
    }
    
    func newState(state: TransitViewState) {
        allRoutes = state.availableRoutes
    }

    func numberOfRows() -> Int {
        guard let filteredRoutes = filteredRoutes else { return 0 }
        return filteredRoutes.count
    }
    
    func configure(cell: RouteTableViewCell, atRow row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count else { return }
        let route = filteredRoutes[row].route
        cell.setShortName(text: "\(route.routeId): \(route.routeShortName)")
        
        cell.setLongName(text: route.routeLongName)
        
        if let routeImage = RouteIcon.get(for: route.routeId, transitMode: route.mode()) {
            cell.setIcon(image: routeImage)
        }
    }
    
    func rowSelected(row: Int) {
        guard let filteredRoutes = filteredRoutes, row < filteredRoutes.count, let slot = slotBeingChanged else { return }
        let route = filteredRoutes[row].route
        
        let action = TransitViewRouteSelected(slot: slot, route: route, description: "TransitView route selected")
        store.dispatch(action)
        let dismissAction = DismissModal(description: "TransitView route selection should be dismissed")
        store.dispatch(dismissAction)
    }
    
    deinit {
        store.unsubscribe(self)
    }
}
