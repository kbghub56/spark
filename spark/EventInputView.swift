//
//  EventInputView.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseDatabase

struct EventInputView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    // Create a reference to your database
    var ref: DatabaseReference!

    init() {
        ref = Database.database().reference()
    }
    
    var body: some View {
        Form {
            Section(header: Text("Event Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                //Add in location feature
            }
            
            Button(action: addEvent) {
                Text("Add Event")
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitle("Add New Event", displayMode: .inline)
    }
    
    func addEvent() {
        // Use the 'ref' to write data to your Realtime Database
        let eventRef = ref.child("events").childByAutoId() // Creates a new child with a unique key

        let eventData: [String: Any] = [
            "title": title,
            "description": description,
            "startDate": startDate.timeIntervalSince1970, // Convert Date to TimeInterval for Firebase
            "endDate": endDate.timeIntervalSince1970
        ]

        eventRef.setValue(eventData) { error, _ in
            if let error = error {
                print("Error adding event: \(error)")
            } else {
                print("Event added successfully")
                // Handle UI updates or feedback here
            }
        }
    }
}

struct EventInputView_Previews: PreviewProvider {
    static var previews: some View {
        EventInputView()
    }
}

