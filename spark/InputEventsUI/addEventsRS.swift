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
    @State private var location: String = ""
    @State private var locationTitle: String = ""
    @State private var locationSubtitle: String = ""
    @State private var selection: String?
    @State private var everyoneText: String = "Everyone"
    @State private var friendsAndMutualsText: String = "Friends and Mutuals Only"
    @State private var friendsOnlyText: String = "Friends Only"
    @ObservedObject var viewModel = EventDateTimeViewModel()
    @StateObject var viewModelLoc = LocationSearchViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 32.5) {
                HStack {
                    Spacer()
                    Text("Add Event")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding(.top, 16)
                
                TextField("Event Name", text: $eventName)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                TextField("Theme, description, etc!", text: $eventDescription)
                    .padding(32)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                locationSearchView().zIndex(1)
                
                HStack {
                    Spacer()
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
                        Spacer()
                    } else {
                        Button("Set Time") {
                            viewModel.isShowingSetTimeView = true
                        }
                        .foregroundColor(.black)
                        .bold()
                        .frame(width: 150, height: 50)
                        .background(Color.white)
                        .cornerRadius(30)
                        Spacer()
                    }
                }
                
                Text("Who's coming?")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
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
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    
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
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    
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
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }
                
                Button(action: addEvent) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(.white)
                .cornerRadius(40)
                .padding(.top, 25)
            }
            .padding(.horizontal, 16)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowingSetTimeView) {
            SetTime(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    private func locationSearchView() -> some View {
        TextField("Location", text: $viewModelLoc.queryFragment)
            .padding()
            .background(Color.gray)
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(
                Group {
                    if !viewModelLoc.results.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(viewModelLoc.results, id: \.self) { result in
                                    LocationSearchResultCell(title: result.title, subtitle: result.subtitle)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                        .onTapGesture {
                                            self.location = result.subtitle
                                            viewModelLoc.queryFragment = result.title
                                            self.locationTitle = result.title
                                            self.locationSubtitle = result.subtitle
                                            // Delay the dismissal of the search results
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                                    viewModelLoc.clearResults()
//                                                }
                                            viewModelLoc.clearResults()
                                        }
                                }
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .frame(height: 300)
                        .offset(y: 45)
                        .zIndex(1)
                    }
                },
                alignment: .topLeading
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
                    "visibility": selection ?? "Everyone",
                    "organizerID": organizerID,
                    "likes": 0,
                    "likedBy": [""],
                    "locationTitle": locationTitle,
                    "locationSubtitle": locationSubtitle,
                ]
                
                let ref = Database.database().reference()
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

struct AddEvents_Previews: PreviewProvider {
    static var previews: some View {
        AddEvents()
    }
}
