//
//  TransitViewMapViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit
import MapKit
import SeptaSchedule
import ReSwift

class TransitViewMapViewController: UIViewController, StoreSubscriber {

    typealias StoreSubscriberStateType = TransitViewModel
    
    var viewModel = TransitViewMapRouteViewModel()
    var routesHaveBeenAdded = false
    var selectedRoute: TransitRoute?
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            addOverlaysToMap()
            drawVehicleLocations()
            mapView.isRotateEnabled = false
            mapView.isAccessibilityElement = false
            mapView.accessibilityElementsHidden = true            
        }
    }
    @IBOutlet weak var addRouteImage: UIImageView! {
        didSet {
            addRouteImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addRouteButtonTapped(_:))))
        }
    }
    @IBOutlet weak var routeCardStackView: UIStackView!
    @IBOutlet weak var route1: TransitRouteCardView!
    @IBOutlet weak var route2: TransitRouteCardView!
    @IBOutlet weak var route3: TransitRouteCardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.transitViewState.transitViewModel
            }.skipRepeats {
                $0 == $1
            }
        }
    }
    
    func newState(state: StoreSubscriberStateType) {
        self.route1.viewModel = state.firstRoute
        self.route1.delegate = self
        self.route2.viewModel = state.secondRoute
        self.route2.delegate = self
        self.route3.viewModel = state.thirdRoute
        self.route3.delegate = self
        
        if route1.viewModel != nil {
            // Default to first route enabled
            route1.enabled = true
            selectedRoute = route1.viewModel
        }
        toggleAddRouteButton(enabled: route3.viewModel == nil)
        
        if route1.viewModel == nil && route2.viewModel == nil && route3.viewModel == nil {
            // No routes! Back we go.
            navigationController?.popViewController(animated: true)
        } else {
            refreshRoutes()
        }
    }
    
    @objc func addRouteButtonTapped(_ sender: UITapGestureRecognizer) {
        var slot: TransitViewRouteSlot
        if route2.viewModel == nil {
            slot = .second
        } else {
            slot = .third
        }
        store.dispatch(TransitViewSlotChange(slot: slot, description: "User wishes to change TransitView slot route"))
        store.dispatch(PresentModal(viewController: .transitViewSelectRouteViewController, description: "User wishes to pick a TransitView route"))
    }
    
    private func toggleAddRouteButton(enabled: Bool) {
        addRouteImage.alpha = enabled ? 1 : 0.5
        addRouteImage.isUserInteractionEnabled = enabled
    }
    
    private var overlaysToAdd = [MKOverlay]() {
        didSet {
            guard let _ = mapView else { return }
            addOverlaysToMap()
            overlaysToAdd.removeAll()
        }
    }
    
    var vehicleAnnotationsAdded = [TransitViewVehicleAnnotation]()
    private var vehiclesToAdd = [TransitViewVehicleLocation]() {
        didSet {
            guard let _ = mapView else { return }
            clearExistingVehicleLocations()
            drawVehicleLocations()
            mapView.showAnnotations(mapView.annotations, animated: false)
            mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
            vehiclesToAdd.removeAll()
        }
    }
    
    private func clearExistingVehicleLocations() {
        mapView.removeAnnotations(vehicleAnnotationsAdded)
        vehicleAnnotationsAdded.removeAll()
    }
    
    private func drawVehicleLocations() {
        for vehicle in vehiclesToAdd {
            drawVehicle(vehicle)
        }
    }
    
    func drawVehicle(_ vehicleLocation: TransitViewVehicleLocation) {
        let annotation = TransitViewVehicleAnnotation(location: vehicleLocation)
        annotation.coordinate = vehicleLocation.coordinate
        if #available(iOS 11.0, *) {
            annotation.title = nil
        } else {
            annotation.title = vehicleLocation.mode.mapTitle()
        }
        
        mapView.addAnnotation(annotation)
        vehicleAnnotationsAdded.append(annotation)
    }

    
    private func addOverlaysToMap() {
        mapView.addOverlays(overlaysToAdd)
    }
    
    private func locateKMLFile(routeId: String) -> URL? {
        guard let url = Bundle.main.url(forResource: routeId, withExtension: "kml") else { return nil }
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        } else {
            print("Could not find kml file for route \(routeId)")
            return nil
        }
    }
    
    private func parseKMLForRoute(url: URL, routeId: String) {
        KMLDocument.parse(url) { [unowned self] kml in
            guard let overlays = kml.overlays as? [KMLOverlayPolyline] else { return }
            let routeOverlays = self.mapOverlaysToRouteOverlays(routeId: routeId, overlays: overlays)
            self.overlaysToAdd = self.overlaysToAdd + routeOverlays
        }
    }
    
    private func mapOverlaysToRouteOverlays(routeId: String, overlays: [KMLOverlayPolyline]) -> [RouteOverlay] {
        return overlays.map { overlay in
            let routeOverlay = RouteOverlay(points: overlay.points(), count: overlay.pointCount)
            routeOverlay.routeId = routeId
            return routeOverlay
        }
    }
    
    private func refreshRoutes() {
        routesHaveBeenAdded = false
        mapView.removeOverlays(mapView.overlays)
        store.dispatch(RefreshTransitViewVehicleLocationData(description: "Request refresh of TransitView vehicle location data"))
    }

}

extension TransitViewMapViewController: MKMapViewDelegate {
    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay = overlay as? RouteOverlay, let routeId = routeOverlay.routeId else { return MKOverlayRenderer(overlay: overlay) }
        let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: routeOverlay)
        
        var routeColor = SeptaColor.transitViewInactiveRoute
        if let selectedRoute = self.selectedRoute, selectedRoute.routeId == routeId {
            routeColor = SeptaColor.transitViewActiveRoute
        }
        renderer.strokeColor = routeColor
        renderer.lineWidth = 2.0
        
        return renderer
    }
    
    func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let transitAnnotation = annotation as? TransitViewVehicleAnnotation else { return nil }
        
        var annotationView: MKAnnotationView
        if let reusableView = mapView.dequeueReusableAnnotationView(withIdentifier: transitAnnotation.annotationId) {
            annotationView = reusableView
        } else {
            annotationView = buildNewAnnotationView(annotation: transitAnnotation)
        }
        
        var activeRoute = false
        if let selectedRoute = self.selectedRoute, selectedRoute.routeId == transitAnnotation.location.routeId {
            activeRoute = true
        }
        annotationView.image = TransitViewVehiclePin.generate(mode: transitAnnotation.location.mode, direction: transitAnnotation.location.heading, active: activeRoute)
        
        if let calloutAccessoryView = annotationView.detailCalloutAccessoryView as? TransitViewVehicleCalloutView {
            calloutAccessoryView.vehicleLocation = transitAnnotation.location
        }
        
        annotationView.annotation = annotation
        return annotationView
    }
    
    func buildNewAnnotationView(annotation: TransitViewVehicleAnnotation) -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.annotationId)
        annotationView.accessibilityElementsHidden = false
        annotationView.accessibilityLabel = "Tap this pin to see vehicle information"
        annotationView.canShowCallout = true
        annotationView.detailCalloutAccessoryView = UIView.loadNibView(nibName: "TransitViewVehicleCalloutView")!
        return annotationView
    }
}

extension TransitViewMapViewController: TransitViewMapDataProviderDelegate {

    func drawRoutes(routeIds: [String]) {
        guard !routesHaveBeenAdded else { return }
        for routeId in routeIds {
            guard let url = locateKMLFile(routeId: routeId) else { return }
            parseKMLForRoute(url: url, routeId: routeId)
            routesHaveBeenAdded = true
        }
    }
    
    func drawVehicleLocations(locations: [TransitViewVehicleLocation]) {
        vehiclesToAdd = locations
    }
}

extension TransitViewMapViewController: TransitRouteCardDelegate {
    func cardTapped(routeId: String) {
        guard let selectedRoute = selectedRoute, selectedRoute.routeId != routeId else { return }
        
        for route in [route1, route2, route3] {
            if let route = route {
                route.enabled = route.viewModel?.routeId == routeId
                if route.viewModel?.routeId == routeId {
                    self.selectedRoute = route.viewModel
                }
            }
        }
        refreshRoutes()
    }
}
