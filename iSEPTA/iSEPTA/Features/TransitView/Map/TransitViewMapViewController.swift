//
//  TransitViewMapViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/10/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import MapKit
import ReSwift
import SeptaSchedule
import UIKit

class TransitViewMapViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = TransitViewModel

    var viewModel = TransitViewMapRouteViewModel()
    var routesHaveBeenAdded = false
    var updateMap = true
    var transitRoutes: [TransitRoute] = [] {
        didSet {
            if transitRoutes.count > 0 {
                toggleFavoriteButton()
            }
        }
    }

    var currentFavorite: Favorite?

    let alerts = store.state.alertState.alertDict

    var delegate: TransitViewMapDelegate?

    var selectedRoute: TransitRoute? {
        didSet {
            for route in [route1, route2, route3] {
                if let route = route, let vm = route.viewModel {
                    route.alertsAreInteractive = vm == selectedRoute
                }
            }
        }
    }

    @IBOutlet var mapView: MKMapView! {
        didSet {
            addOverlaysToMap()
            drawVehicleLocations()
            mapView.isRotateEnabled = false
            mapView.isAccessibilityElement = false
            mapView.accessibilityElementsHidden = true
        }
    }

    @IBOutlet var addRouteImage: UIImageView! {
        didSet {
            addRouteImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addRouteButtonTapped(_:))))
        }
    }

    @IBOutlet var routeCardStackView: UIStackView!
    @IBOutlet var route1: TransitRouteCardView!
    @IBOutlet var route2: TransitRouteCardView!
    @IBOutlet var route3: TransitRouteCardView!

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
        configureRouteCards(model: state)

        toggleAddRouteButton(enabled: route3.viewModel == nil)

        transitRoutes = []
        for route in [route1.viewModel, route2.viewModel, route3.viewModel] {
            if let route = route {
                transitRoutes.append(route)
            }
        }

        if route1.viewModel == nil && route2.viewModel == nil && route3.viewModel == nil {
            // No routes! Back we go.
            navigationController?.popViewController(animated: true)
        } else {
            refreshRoutes()
        }
    }

    func favoriteButtonTapped() {
        if let currentFavorite = currentFavorite {
            let action = EditFavorite(favorite: currentFavorite)
            store.dispatch(action)
        } else {
            let newFavorite = createNewFavorite()
            currentFavorite = newFavorite
            let action = AddFavorite(favorite: newFavorite)
            store.dispatch(action)
            delegate?.selectionIsAFavorite(isAFavorite: true)
        }
    }

    private func createNewFavorite() -> Favorite {
        var favoriteName = ""
        for route in transitRoutes {
            if favoriteName != "" {
                favoriteName.append(", ")
            }
            let modeName = route.mode() == .bus ? "Bus" : "Trolley"
            favoriteName.append("\(route.routeId) \(modeName)")
        }

        return Favorite(favoriteType: .transitView, favoriteId: UUID().uuidString, favoriteName: favoriteName, transitMode: .bus, selectedRoute: Favorite.emptyRoute, selectedStart: Favorite.emptyStop, selectedEnd: Favorite.emptyStop, transitViewRoutes: transitRoutes)
    }

    private func configureRouteCards(model: TransitViewModel) {
        route1.viewModel = model.firstRoute
        route1.delegate = self
        route2.viewModel = model.secondRoute
        route2.delegate = self
        route3.viewModel = model.thirdRoute
        route3.delegate = self

        if route1.viewModel != nil {
            // Default to first route enabled
            route1.enabled = true
            selectedRoute = route1.viewModel
        }

        // Configure route alerts
        for route in [route1, route2, route3] {
            if let route = route, let vm = route.viewModel {
                let routeAlert = alerts[vm.mode()]?[vm.routeId]
                route.addAlert(routeAlert)
                route.alertsAreInteractive = route.enabled
            }
        }
    }

    private func toggleFavoriteButton() {
        var thisIsAFavorite = false
        let transitViewFavorites = store.state.favoritesState.favorites.filter { $0.favoriteType == .transitView }

        for fav in transitViewFavorites {
            thisIsAFavorite = amITheSameAsThisFavorite(favorite: fav)
            if thisIsAFavorite {
                currentFavorite = fav
                break
            }
        }

        delegate?.selectionIsAFavorite(isAFavorite: thisIsAFavorite)
    }

    private func amITheSameAsThisFavorite(favorite: Favorite) -> Bool {
        if transitRoutes.count != favorite.transitViewRoutes.count {
            return false
        }
        for route in favorite.transitViewRoutes {
            if !transitRoutes.contains(route) {
                return false
            }
        }
        return true
    }

    @objc func addRouteButtonTapped(_: UITapGestureRecognizer) {
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
            if updateMap {
                mapView.showAnnotations(mapView.annotations, animated: false)
                mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0), animated: true)
            }
            if !updateMap {
                updateMap = true
            }
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

    private func activateRouteById(routeId: String) {
        for route in [route1, route2, route3] {
            if let route = route, let vm = route.viewModel {
                route.enabled = vm.routeId == routeId
                if vm.routeId == routeId {
                    selectedRoute = route.viewModel
                }
            }
        }
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

        var annotationView: TransitViewAnnotationView
        if let reusableView = mapView.dequeueReusableAnnotationView(withIdentifier: transitAnnotation.annotationId) as? TransitViewAnnotationView {
            annotationView = reusableView
        } else {
            annotationView = buildNewAnnotationView(annotation: transitAnnotation)
        }

        var activeRoute = false
        if let selectedRoute = self.selectedRoute, selectedRoute.routeId == transitAnnotation.location.routeId {
            activeRoute = true
        }
        annotationView.canShowCallout = activeRoute
        annotationView.routeId = transitAnnotation.location.routeId
        annotationView.isActiveRoute = activeRoute
        annotationView.image = TransitViewVehiclePin.generate(mode: transitAnnotation.location.mode, direction: transitAnnotation.location.heading, active: activeRoute)

        if let calloutAccessoryView = annotationView.detailCalloutAccessoryView as? TransitViewVehicleCalloutView {
            calloutAccessoryView.vehicleLocation = transitAnnotation.location
        }
        annotationView.annotation = annotation
        return annotationView
    }

    func buildNewAnnotationView(annotation: TransitViewVehicleAnnotation) -> TransitViewAnnotationView {
        let annotationView = TransitViewAnnotationView(annotation: annotation, reuseIdentifier: annotation.annotationId)
        annotationView.delegate = self
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

        activateRoute(routeId: routeId)
    }
}

extension TransitViewMapViewController: TransitViewAnnotationViewDelegate {
    func activateRoute(routeId: String) {
        // Just switching active route, so don't update the whole map
        updateMap = false

        // Set new active route ID
        activateRouteById(routeId: routeId)

        // Clear old overlays
        mapView.removeOverlays(mapView.overlays)
        routesHaveBeenAdded = false

        // Add overlays back
        drawRoutes(routeIds: transitRoutes.map { $0.routeId })

        // Clear old annotations
        let previouslyAddedAnnotations = vehicleAnnotationsAdded.map { $0.location }
        clearExistingVehicleLocations()

        // Add annotations back
        vehiclesToAdd = previouslyAddedAnnotations
    }
}

protocol TransitViewMapDelegate {
    func selectionIsAFavorite(isAFavorite: Bool)
}
