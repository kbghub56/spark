import SwiftUI
import Firebase
import FirebaseDatabase
import CoreLocation
import FirebaseAuth
// DateFormatter extension remains unchanged
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}
struct AddEvents: View {
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var location: String = "" // Corrected from using eventName for location
    @State private var selection: String?
    @State private var everyoneText: String = "Everyone"
    @State private var friendsAndMutualsText: String = "Friends and Mutuals Only"
    @State private var friendsOnlyText: String = "Friends Only"
    @ObservedObject var viewModel = EventDateTimeViewModel()
    @StateObject var viewModelLoc = LocationSearchViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .frame(width: 364, height: 612)
                    .foregroundColor(Color.black.opacity(0.8))
                    .cornerRadius(42)
                Rectangle()
                    .frame(width: 346, height: 596)
                    .foregroundColor(.black)
                    .cornerRadius(40)
                VStack(spacing: 25) {
                    Group {
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(red: 0.99, green: 0.01, blue: 0.01).opacity(0.44))
                            .offset(x: 140, y: 120)
                        Rectangle()
                            .frame(width: 5, height: 20)
                            .background(Color.black)
                            .cornerRadius(90)
                            .rotationEffect(.degrees(-45))
                            .offset(x: 140, y: 70)
                        Rectangle()
                            .frame(width: 5, height: 20)
                            .background(Color.black)
                            .cornerRadius(90)
                            .rotationEffect(.degrees(45))
                            .offset(x: 140, y: 25)
                    }
                    Text("Add Event")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 0, y: 10)
                    TextField("Event Name", text: $eventName)
                        .padding()
                        .frame(width: 274, height: 50)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    TextField("Theme, description, attire, etc.", text: $eventDescription)
                        .padding()
                        .frame(width: 274, height: 100)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    locationSearchView().zIndex(1)
                    
                        
                    if viewModel.timeHasBeenSet {
                        VStack {
                            Text("Starts at \(viewModel.startTime, formatter: DateFormatter.timeFormatter)")
                                .foregroundColor(.white)
                            Button("Change") {
                                viewModel.isShowingSetTimeView = true
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        }
                    } else {
                        Button("Set Time") {
                            viewModel.isShowingSetTimeView = true
                        }
                        .foregroundColor(.black)
                        .frame(width: 250, height: 75)
                        .background(Color.white)
                        .cornerRadius(40)
                    }
                    Text("Who's coming?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 0, y: -5)
                    VStack(alignment: .leading, spacing: 15) {
                        Button(action: {
                            selection = "Everyone"
                            everyoneText = "Let's Rage 🎉"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                everyoneText = "Everyone"
                            }
                        }) {
                            HStack {
                                Image(systemName: selection == "Everyone" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.white)
                                Text(everyoneText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fixed width for the text
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensuring the button takes full available width
                        .padding(.horizontal) // Optional, for padding on both sides if needed
                        .offset(x: 100)
                        Button(action: {
                            selection = "Friends and Mutuals Only"
                            friendsAndMutualsText = "Kickback 🤗"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                friendsAndMutualsText = "Friends and Mutuals Only"
                            }
                        }) {
                            HStack {
                                Image(systemName: selection == "Friends and Mutuals Only" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.white)
                                Text(friendsAndMutualsText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fixed width for the text
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensuring the button takes full available width
                        .padding(.horizontal) // Optional, for padding on both sides if needed
                        .offset(x: 100)
                        Button(action: {
                            selection = "Friends Only"
                            friendsOnlyText = "Small hangout 😄"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                friendsOnlyText = "Friends Only"
                            }
                        }) {
                            HStack {
                                Image(systemName: selection == "Friends Only" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.white)
                                Text(friendsOnlyText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fixed width for the text
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensuring the button takes full available width
                        .padding(.horizontal) // Optional, for padding on both sides if needed
                        .offset(x: 100)
                    }
                    
                    Button(action: addEvent) {
                        Text("Done")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.black)
                            .frame(width: 180, height: 60)
                            .background(Color.white)
                            .cornerRadius(60)
                    }
                    
                }
                
            }
            .offset(y: -70)
            .frame(width: 430, height: 932)
            .background(.black)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.isShowingSetTimeView) {
            SetTime(viewModel: viewModel)
        }
    }
    
    // Location Search integrated within the EventDetailsView
    @ViewBuilder
    private func locationSearchView() -> some View {
        TextField("Location", text: $viewModelLoc.queryFragment)
            .padding()
            .frame(width: 274, height: 50)
            .background(Color.gray)
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(
                // Conditional overlay for search results
                Group {
                    if !viewModelLoc.results.isEmpty {
                        ScrollView{
                            VStack(alignment: .leading) {
                                ForEach(viewModelLoc.results, id: \.self) { result in
                                    LocationSearchResultCell(title: result.title, subtitle: result.subtitle)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                        .onTapGesture {
                                            // Update location with the selected result and clear results
                                            self.location = result.subtitle
                                            viewModelLoc.queryFragment = result.title
                                            viewModelLoc.clearResults()
                                        }
                                }
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemBackground)) // Use an appropriate background color
                        .cornerRadius(10)
                        .shadow(radius: 5) // Optional shadow for better visibility
                        .frame(width: 274, height: 300) // Match the width of the TextField
                        
                        // Position the results just below the TextField
                        .offset(y: 45)
                        .zIndex(1)
                    }
                },
                alignment: .topLeading // Align the overlay to the top leading edge of the TextField
            )
    }
    
    private func addEvent() {
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
                        "startDate": viewModel.startTime.timeIntervalSince1970,
                        "endDate": viewModel.endTime.timeIntervalSince1970,
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude,
                        "visibility": selection ?? "Everyone", // Default to "Everyone" if no selection
                        "organizerID": organizerID,
                        "likes": 0,  // Initialize likes count
                        "likedBy": [""]  // Initialize empty array for user IDs who liked the event
                    ]

                    let ref = Database.database().reference() // Adjust this line based on your Firebase setup
                    let eventRef = ref.child("events").childByAutoId()
                    eventRef.setValue(eventData) { error, _ in
                        if let error = error {
                            print("Error adding event: \(error)")
                        } else {
                            print("Event added successfully")
                            presentationMode.wrappedValue.dismiss() // Dismiss the view on success
                        }
                    }
                } else {
                    print("No valid coordinates found for the address")
                }
            }
        }

}



struct AddEvents_Previews: PreviewProvider {
    static var previews: some View {
        AddEvents()
    }
}

