//
//  TripDetailMapViewDelegate.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import MapKit
import SeptaRest
import SeptaSchedule

class PushNotificationTripDetailMapViewDelegate: NSObject, MKMapViewDelegate {
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
        case let annotation as PushNotificationTripDetailVehicleLocationAnnotation:
            return retrieveVehicleAnnotationView(annotation: annotation, mapView: mapView)
        default:
            return nil
        }
    }

    func retrieveVehicleAnnotationView(annotation: PushNotificationTripDetailVehicleLocationAnnotation, mapView: MKMapView) -> MKAnnotationView? {
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
            buildVehicleTitle(data: annotation.tripDetailData, calloutView: calloutAccessoryView)
        }

        annotationView.annotation = annotation

        return annotationView
    }

    func buildVehicleTitle(data: PushNotificationTripDetailData, calloutView: UIView?) {
        guard let calloutView = calloutView as? MapVehicleCalloutView else { return }

        configureDelayLabel(delay: data.destinationDelay, label: calloutView.label2)
        configureTrainToLastStopLabel(lastStopName: data.destinationStation, tripId: data.tripId, label: calloutView.label1)
        configureRailVehicleIDLabel(railCars: data.consist, label: calloutView.label3)


    }

    func configureDelayLabel(delay: Int?, label: UILabel) {
        let delayString = generateDelayString(prefixString: "Status: ", delay: delay)
        if let delayString = delayString {
            label.text = delayString
        } else {
            label.text = "Status: No Realtime data"
        }
    }

    func generateDelayString(prefixString: String, delay: Int?) -> String? {
        let defaultString = "Scheduled"

        guard let delay = delay else { return nil }

        let delayString: String?
        switch delay {
        case let delay where delay <= 0:
            delayString = "\(prefixString)On Time"

        case let delay where delay > 0:
            delayString = "\(prefixString)\(delay) min late"

        default:
            delayString = defaultString
        }
        return delayString
    }


    func configureTrainToLastStopLabel(lastStopName: String?, tripId: String?, label: UILabel) {
        if let tripId = tripId, let lastStopName = lastStopName {
            label.text = "Train: #\(tripId) to \(lastStopName)"
        } else {
            label.text = ""
        }
    }

    func configureRailVehicleIDLabel(railCars: [String]?, label: UILabel) {
        if let vehicleIds = railCars {
            label.text = "# of Train Cars: \(vehicleIds.count)"
        } else {
            label.text = "# of Train Cars: unknown"
        }
    }

    func buildNewVehicleAnnotationView(annotation: PushNotificationTripDetailVehicleLocationAnnotation, vehicleViewId: String) -> MKAnnotationView? {
        let transitMode = TransitMode.rail
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
