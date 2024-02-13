//
//  EventInputView.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import CoreLocation

struct EventInputView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var location: String = "" // This will hold the final location string
    @StateObject var viewModel = LocationSearchViewModel()
    @Environment(\.presentationMode) var presentationMode

    
    var ref: DatabaseReference = Database.database().reference()
    
    var body: some View {
        Form {
            Section(header: Text("Event Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            }
            // Only one section for Location
            Section(header: Text("Location")) {
                TextField("Location", text: $viewModel.queryFragment)
                // Conditional ScrollView to show results only when there are any
                if !viewModel.results.isEmpty {
                   ScrollView {
                       VStack(alignment: .leading) {
                           ForEach(viewModel.results, id: \.self) { result in
                               LocationSearchResultCell(title: result.title, subtitle: result.subtitle)
                                   .onTapGesture {
                                       // Update location with the selected result
                                       self.location = result.subtitle
                                       viewModel.queryFragment = result.title
                                       viewModel.clearResults()
                                   }
                           }
                       }
                   }
                   .frame(maxHeight: 200) // Limit the height of the ScrollView
                }
            }
            Button(action: addEvent) {
                Text("Add Event")
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitle("Add New Event", displayMode: .inline)
    }

    func addEvent() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }

            if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate {
                let eventData: [String: Any] = [
                    "title": self.title,
                    "description": self.description,
                    "startDate": self.startDate.timeIntervalSince1970,
                    "endDate": self.endDate.timeIntervalSince1970,
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude
                ]

                let eventRef = self.ref.child("events").childByAutoId()
                eventRef.setValue(eventData) { error, _ in
                    if let error = error {
                        print("Error adding event: \(error)")
                    } else {
                        print("Event added successfully")
                        // Optionally, navigate back to the map view or indicate success to the user
                    }
                }
            } else {
                print("No valid coordinates found for the address")
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct EventInputView_Previews: PreviewProvider {
    static var previews: some View {
        EventInputView()
    }
}
