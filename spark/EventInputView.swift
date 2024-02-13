//
//  EventInputView.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import SwiftUI
import Firebase
import FirebaseDatabase

struct EventInputView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var location: String = "" // This will hold the final location string
    @StateObject var viewModel = LocationSearchViewModel()
    
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
        let eventData: [String: Any] = [
            "title": title,
            "description": description,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970,
            "location": location // Final location string
        ]

        let eventRef = ref.child("events").childByAutoId()
        eventRef.setValue(eventData) { error, _ in
            if let error = error {
                print("Error adding event: \(error)")
            } else {
                print("Event added successfully")
            }
        }
    }
}

struct EventInputView_Previews: PreviewProvider {
    static var previews: some View {
        EventInputView()
    }
}
