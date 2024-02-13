//
//  EventViewModel.swift
//  spark
//
//  Created by Kabir Borle on 2/13/24.
//

import FirebaseDatabase
import CoreLocation
import SwiftUI

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []

    init() {
        fetchEvents()
    }

    private func fetchEvents() {
        let ref = Database.database().reference(withPath: "events")
        ref.observe(.value, with: { snapshot in
            var newEvents: [Event] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let title = dict["title"] as? String,
                   let description = dict["description"] as? String,
                   let startDate = dict["startDate"] as? TimeInterval,
                   let endDate = dict["endDate"] as? TimeInterval,
                   let latitude = dict["latitude"] as? Double,
                   let longitude = dict["longitude"] as? Double {
                    let event = Event(id: snapshot.key, title: title, description: description, startDate: Date(timeIntervalSince1970: startDate), endDate: Date(timeIntervalSince1970: endDate), latitude: latitude, longitude: longitude)
                    newEvents.append(event)
                }
            }
            
            DispatchQueue.main.async {
                self.events = newEvents
            }
        })
    }
}

struct Event: Identifiable {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let latitude: Double
    let longitude: Double
}
