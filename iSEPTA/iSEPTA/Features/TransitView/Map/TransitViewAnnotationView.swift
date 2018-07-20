//
//  TransitViewAnnotationView.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/20/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import MapKit

class TransitViewAnnotationView: MKAnnotationView {
 
    var delegate: TransitViewAnnotationViewDelegate?
    var routeId: String?
    var isActiveRoute: Bool = true
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        if let vehicleAnnotation = annotation as? TransitViewVehicleAnnotation {
            routeId = vehicleAnnotation.location.routeId
        }
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            // Allow selected only if this view is for the active route
            super.setSelected(isActiveRoute, animated: animated)
            // If this view is part of a route that is not active, the setSelected action should activate the route
            guard let routeId = routeId else { return }
            if !isActiveRoute {
                delegate?.activateRoute(routeId: routeId)
            }
        } else {
            // This is a deselect action. We'll allow it
            super.setSelected(selected, animated: animated)
        }
    }
}


protocol TransitViewAnnotationViewDelegate {
    func activateRoute(routeId: String)
}
