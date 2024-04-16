//
//  EventAnnotationModel.swift
//  spark
//
//  Created by Kabir Borle on 3/10/24.
//

import SwiftUI
import MapKit

class EventAnnotation: NSObject, MKAnnotation, Identifiable {
    let id: String
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var likedBy: [String]
    let visibility: String  // Add this line
    let locSub: String
    let locTitle: String
    let startDate: Date
    let endDate: Date
    

    init(event: Event) {
        self.id = event.id
        self.title = event.title
        self.subtitle = event.description
        self.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        self.likedBy = event.likedBy
        self.visibility = event.visibility  // Ensure Event model has this property and it's populated
        self.locSub = event.locSubtitle
        self.locTitle = event.locTitle
        self.likedBy = event.likedBy
        self.startDate = event.startDate
        self.endDate = event.endDate
        
    }
}
