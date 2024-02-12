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
        
    }
}

struct EventInputView_Previews: PreviewProvider {
    static var previews: some View {
        EventInputView()
    }
}
