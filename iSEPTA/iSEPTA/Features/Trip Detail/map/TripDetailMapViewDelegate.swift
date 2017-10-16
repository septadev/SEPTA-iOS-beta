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
        if let vehicleView = mapView.dequeueReusableAnnotationView(withIdentifier: vehicleId){
            annotationView = vehicleView
        } else {
            let maybeAnnotionView = buildNewVehicleAnnotationView(annotation: annotation, vehicleViewId: vehicleId)
            if let newAnnotionView = maybeAnnotionView {
                annotationView = newAnnotionView
            } else {
                return nil
            }
            
        }

        buildVehicleTitle(vehicleLocation: annotation.vehicleLocation, calloutView: annotationView.detailCalloutAccessoryView)
        annotationView.annotation = annotation
        //        if annotation.vehicleLocation.isMoving, let bearing = annotation.vehicleLocation.bearing {
        //            let startingTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        //            let transformForBearing = startingTransform.rotated(by: CGFloat(bearing))
        //            //            vehicleView.transform = transformForBearing
        //        }
        return annotationView
    }

    func buildVehicleTitle(vehicleLocation: VehicleLocation, calloutView: UIView?) {
        guard let calloutView = calloutView as? MapVehicleCalloutView , let transitMode = tripDetails?.transitMode else { return }

        if let detail = vehicleLocation.nextToArriveStop.nextToArriveDetail as? NextToArriveRailDetails,
            let consist = detail.consist, let destination = detail.destination, let delay = detail.destinationDelay, let tripId = detail.tripid {
                let countString = String(consist.count)
                let delayString = buildDelayString(delay:delay)
                calloutView.label1.text = "Train: #\(tripId) to \(destination)"
                calloutView.label2.text = delayString
                calloutView.label3.text = "# of Train Cars: \(countString)"
                return
            }
        if let detail = vehicleLocation.nextToArriveStop.nextToArriveDetail as? NextToArriveBusDetails,
            let vehicleId = detail.vehicleid, let destination = detail.destinationStation, let delay = detail.destinationDelay, let blockId = detail.blockid {

                let delayString = buildDelayString(delay:delay)
                calloutView.label1.text = "Block ID: \(blockId) to \(destination)"
                calloutView.label2.text = "Vehicle Number: \(vehicleId)"
                calloutView.label3.text = delayString
                return
            }
        let stop = vehicleLocation.nextToArriveStop

        if transitMode.useBusForDetails(){
           if let lastStopName = stop.lastStopName {
                calloutView.label1.text = "#\(stop.routeId):  to \(lastStopName)"
           } else {
                calloutView.label1.text = ""
           }

           if let vehicleIds = stop.vehicleIds, let firstVehicle = vehicleIds.first {
                calloutView.label2.text = "Vehicle Number: \(firstVehicle)"
           } else {
                calloutView.label3.text = "Vehicle Number not available"
           }

           if let delay = stop.delayMinutes {
                let delayString = buildDelayString(delay:delay)
                calloutView.label3.text = delayString
           } else {
                calloutView.label3.text = "Status: No Realtime data"
           }
            return
        }

           if transitMode.useRailForDetails(){
           if let  tripId = stop.tripId , let lastStopName = stop.lastStopName{
                calloutView.label1.text = "Train: #\(tripId) to \(lastStopName)"
           } else {
                calloutView.label1.text = ""
           }

        if let delay = stop.delayMinutes {
                let delayString = buildDelayString(delay:delay)
                calloutView.label2.text = delayString
           } else {
                calloutView.label2.text = "Status: No Realtime data"
           }

           if let vehicleIds = stop.vehicleIds {
                calloutView.label3.text = "# of Train Cars: \(vehicleIds.count)"
           } else {
                calloutView.label3.text = "# of Train Cars: unknown"
           }

         return

        }

          calloutView.label1.text = ""
                calloutView.label2.text = ""
                calloutView.label3.text = ""

    }

    func buildDelayString(delay: Int) -> String {
        let delayString: String
                switch delay {
                    case let delay where delay < 0:
                    delayString = "Status: \(delay) min early"
                    case 0:
                    delayString = "Status: On Time"
                    case  let delay where delay > 0:
                    delayString = "Status: \(delay) min late"
                    default:
                    delayString = ""
                }
        return delayString
    }

    func buildNewVehicleAnnotationView(annotation: VehicleLocationAnnotation, vehicleViewId: String) -> MKAnnotationView? {
        let transitMode = annotation.vehicleLocation.nextToArriveStop.transitMode
        let vehicleView = MKAnnotationView(annotation: annotation, reuseIdentifier: vehicleViewId)
        vehicleView.image = transitMode.mapPin()
        vehicleView.canShowCallout = true
        vehicleView.detailCalloutAccessoryView = UIView.loadNibView(nibName: "MapVehicleCalloutView")!
        return vehicleView
    }

    func mapView(_: MKMapView, didSelect annotationView: MKAnnotationView) {
        print("User Selected a pin")
    }

    func mapViewDidFinishLoadingMap(_: MKMapView) {
        print("Map View Finished Loading")
    }
}
