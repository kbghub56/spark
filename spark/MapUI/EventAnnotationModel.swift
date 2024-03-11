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

    init(event: Event) {
        self.id = event.id
        self.title = event.title
        self.subtitle = event.description
        self.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
    }
}

 
