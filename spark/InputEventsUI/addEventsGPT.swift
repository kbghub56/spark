//
//  addEventsGPT.swift
//  spark
//
//  Created by Kabir Borle on 2/27/24.
//
import SwiftUI
import Firebase
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

struct AddEvents1: View {
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var selectedVisibility: Event.EventVisibility = .publicEvent
    @ObservedObject var viewModel = EventDateTimeViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var ref: DatabaseReference = Database.database().reference()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Event Details")) {
                        TextField("Event Name", text: $eventName)
                        TextField("Theme, description, attire, etc.", text: $eventDescription)
                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section(header: Text("Location")) {
                        TextField("Location", text: $location)
                    }
                    
                    Section(header: Text("Visibility")) {
                        Picker("Visibility", selection: $selectedVisibility) {
                            Text("Public").tag(Event.EventVisibility.publicEvent)
                            Text("Friends").tag(Event.EventVisibility.friendsOnly)
                            Text("Friends & Mutuals").tag(Event.EventVisibility.friendsAndMutuals)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Button(action: addEvent) {
                        Text("Add Event")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationBarTitle("Add New Event", displayMode: .inline)
        }
    }
    
    func addEvent() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate {
                guard let organizerID = Auth.auth().currentUser?.uid else {
                    print("Failed to retrieve organizer ID")
                    return
                }
                
                let eventData: [String: Any] = [
                    "title": eventName,
                    "description": eventDescription,
                    "startDate": startDate.timeIntervalSince1970,
                    "endDate": endDate.timeIntervalSince1970,
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude,
                    "visibility": selectedVisibility.rawValue,
                    "organizerID": organizerID
                ]
                
                let eventRef = ref.child("events").childByAutoId()
                eventRef.setValue(eventData) { error, _ in
                    if let error = error {
                        print("Error adding event: \(error)")
                    } else {
                        print("Event added successfully")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                print("No valid coordinates found for the address")
            }
        }
    }
}

struct AddEvents1_Previews: PreviewProvider {
    static var previews: some View {
        AddEvents()
    }
}
