//
//  EventAnnotationModel.swift
//  spark
//
//  Created by Kabir Borle on 3/10/24.
//

import SwiftUI
import MapKit

class EventAnnotation: NSObject, MKAnnotation {
    let id: String
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var likedBy: [String]  // Add this line

    init(event: Event) {
        self.id = event.id
        self.title = event.title
        self.subtitle = event.description
        self.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        self.likedBy = event.likedBy  // Ensure Event model has this property and it's populated
    }
}

