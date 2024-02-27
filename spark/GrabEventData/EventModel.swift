//
//  EventModel.swift
//  spark
//
//  Created by Kabir Borle on 2/24/24.
//

import SwiftUI

struct Event: Identifiable {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let latitude: Double
    let longitude: Double
    let visibility: EventVisibility
    let organizerID: String

    enum EventVisibility: String {
        case publicEvent = "public"
        case friendsOnly = "friends"
        case friendsAndMutuals = "friendsAndMutuals"
    }

    init(id: String, title: String, description: String, startDate: Date, endDate: Date, latitude: Double, longitude: Double, visibility: String, organizerID: String) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.latitude = latitude
        self.longitude = longitude
        self.visibility = EventVisibility(rawValue: visibility) ?? .publicEvent
        self.organizerID = organizerID
    }
}
