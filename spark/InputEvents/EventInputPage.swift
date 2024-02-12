//
//  EventInputPage.swift
//  spark
//
//  Created by Kabir Borle on 2/10/24.
//

import SwiftUI
import Firebase

struct EventInputView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Button(action: addEvent) {
                    Text("Add Event")
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle("Add New Event", displayMode: .inline)
        }
    }
    
    func addEvent() {
        // Implement the functionality to add the event to Firestore here
        print("Event Title: \(title)")
        print("Event Description: \(description)")
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        // Ensure Firestore is initialized
        let db = Firestore.firestore()
        
        // Create a dictionary of event data
        let eventData: [String: Any] = [
            "title": title,
            "description": description,
            "startDate": startDate,
            "endDate": endDate,
            "timestamp": FieldValue.serverTimestamp() // Captures the server's current timestamp
        ]
        
        // Add a new document to the 'events' collection
        db.collection("events").addDocument(data: eventData) { error in
            if let error = error {
                // Handle the error appropriately in your app
                print("Error adding document: \(error)")
            } else {
                // Optionally, clear the form fields or give user feedback
                print("Document added successfully")
            }
        }
    }
}

struct EventInputView_Previews: PreviewProvider {
    static var previews: some View {
        EventInputView()
    }
}
