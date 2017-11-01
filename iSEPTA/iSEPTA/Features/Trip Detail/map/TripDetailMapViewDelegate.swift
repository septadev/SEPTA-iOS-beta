//
//  TripDetailMapViewDelegate.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import MapKit
import SeptaSchedule
import SeptaRest

class TripDetailMapViewDelegate: NSObject, MKMapViewDelegate {

    var tripDetails: NextToArriveStop?

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeOverlay = overlay as? RouteOverlay, let routeId = routeOverlay.routeId else { return MKOverlayRenderer(overlay: overlay) }
        let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: routeOverlay)

        renderer.strokeColor = Route.colorForRouteId(routeId, transitMode: .bus)
        renderer.lineWidth = 2.0

        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {

        case let annotation as VehicleLocationAnnotation:
            return retrieveVehicleAnnotationView(annotation: annotation, mapView: mapView)
        default:
            return nil
        }
    }

    func retrieveVehicleAnnotationView(annotation: VehicleLocationAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        let vehicleId = "vehicle"
        let annotationView: MKAnnotationView
        if let vehicleView = mapView.dequeueReusableAnnotationView(withIdentifier: vehicleId) {
            annotationView = vehicleView
        } else {
            let maybeAnnotionView = buildNewVehicleAnnotationView(annotation: annotation, vehicleViewId: vehicleId)
            if let newAnnotionView = maybeAnnotionView {
                annotationView = newAnnotionView
            } else {
                return nil
            }
        }

        if let calloutAccessoryView = annotationView.detailCalloutAccessoryView as? MapVehicleCalloutView {
            calloutAccessoryView.buildCalloutView(vehicleLocation: annotation.vehicleLocation)
        }

        annotationView.annotation = annotation

        return annotationView
    }

    func buildVehicleTitle(vehicleLocation: VehicleLocation, calloutView: UIView?) {
        guard let calloutView = calloutView as? MapVehicleCalloutView else { return }

        let nextToArriveStop = vehicleLocation.nextToArriveStop

        let transitMode = nextToArriveStop.transitMode

        if let detail = vehicleLocation.nextToArriveStop.nextToArriveDetail as? NextToArriveRailDetails,
            let consist = detail.consist, let destination = detail.destination, let tripId = detail.tripid {
            let countString = String(consist.count)
            calloutView.label1.text = "Train: #\(tripId) to \(destination)"
            configureDelayLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label2)
            calloutView.label3.text = "# of Train Cars: \(countString)"
            return
        }
        if let detail = vehicleLocation.nextToArriveStop.nextToArriveDetail as? NextToArriveBusDetails,
            let vehicleId = detail.vehicleid, let destination = detail.destinationStation, let blockId = detail.blockid {

            calloutView.label1.text = "Block ID: \(blockId) to \(destination)"
            calloutView.label2.text = "Vehicle Number: \(vehicleId)"
            configureDelayLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label3)
            return
        }

        if transitMode.useBusForDetails() {

            configureBusToLastStopLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label1)

            configureBusVehicleIDLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label2)

            configureDelayLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label3)
            return
        }

        if transitMode.useRailForDetails() {

            configureTrainToLastStopLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label1)

            configureDelayLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label2)

            configureRailVehicleIDLabel(nextToArriveStop: nextToArriveStop, label: calloutView.label3)

            return
        }

        calloutView.label1.text = ""
        calloutView.label2.text = ""
        calloutView.label3.text = ""
    }

    func configureDelayLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        let delayString = nextToArriveStop.generateDelayString()
        if let delayString = delayString {
            label.text = delayString
        } else {
            label.text = "Status: No Realtime data"
        }
    }

    func configureTrainToLastStopLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let tripId = nextToArriveStop.tripId, let lastStopName = nextToArriveStop.lastStopName {
            label.text = "Train: #\(tripId) to \(lastStopName)"
        } else {
            label.text = ""
        }
    }

    func configureBusToLastStopLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let lastStopName = nextToArriveStop.lastStopName {
            label.text = "#\(nextToArriveStop.routeId):  to \(lastStopName)"
        } else {
            label.text = ""
        }
    }

    func configureBusVehicleIDLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let vehicleIds = nextToArriveStop.vehicleIds, let firstVehicle = vehicleIds.first {
            label.text = "Vehicle Number: \(firstVehicle)"
        } else {
            label.text = "Vehicle Number not available"
        }
    }

    func configureRailVehicleIDLabel(nextToArriveStop: NextToArriveStop, label: UILabel) {
        if let vehicleIds = nextToArriveStop.vehicleIds {
            label.text = "# of Train Cars: \(vehicleIds.count)"
        } else {
            label.text = "# of Train Cars: unknown"
        }
    }

    func buildNewVehicleAnnotationView(annotation: VehicleLocationAnnotation, vehicleViewId: String) -> MKAnnotationView? {
        let transitMode = annotation.vehicleLocation.nextToArriveStop.transitMode
        let vehicleView = MKAnnotationView(annotation: annotation, reuseIdentifier: vehicleViewId)
        vehicleView.image = transitMode.mapPin()
        vehicleView.canShowCallout = true
        vehicleView.detailCalloutAccessoryView = UIView.loadNibView(nibName: "MapVehicleCalloutView")!
        return vehicleView
    }

    func mapView(_: MKMapView, didSelect _: MKAnnotationView) {
        print("User Selected a pin")
    }

    func mapViewDidFinishLoadingMap(_: MKMapView) {
        print("Map View Finished Loading")
    }
}
