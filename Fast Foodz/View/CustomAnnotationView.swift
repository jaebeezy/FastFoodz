//
//  CustomAnnotationView.swift
//  Fast Foodz
//
//  Created by Jae Young Choi on 2/19/22.
//

import MapKit

/// Need to utlize a custom MKAnnotationView object to change the pin's image
class CustomAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = false
            image = UIImage(named: "pin")
        }
    }
}

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
