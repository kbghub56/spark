//
//  CoordinatorClass.swift
//  spark
//
//  Created by Kabir Borle on 2/25/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth


class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapViewRepresentable

    init(_ parent: MapViewRepresentable) {
        self.parent = parent
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // Return nil so map view draws "blue dot" for standard user location
            return nil
        }

        let identifier = "annotation"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        // Customize the annotation view based on the annotation title
        if let title = annotation.title as? String, title.contains("Friend") {
            view.markerTintColor = .green
            view.glyphImage = UIImage(systemName: "person.fill")
        } else if let title = annotation.title as? String, title.contains("Event") {
            view.markerTintColor = .red
            view.glyphImage = UIImage(systemName: "star.fill")
        } else {
            // Default color for any other annotations
            view.markerTintColor = .purple
        }

        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Handle annotation selection for more interaction
        // For example, you could present a detail view of the event or friend
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Handle annotation deselection if needed
    }
}
