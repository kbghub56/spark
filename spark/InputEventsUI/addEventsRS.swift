import SwiftUI
import Firebase
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

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
    @State private var isShowingSetTimePopup = false
    @State private var errorMessage: String?
    @State private var isLocationSelected: Bool = false
    @State private var isFormValid: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.slide)
                    .zIndex(1)
                    .offset(y: -350)
            }
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
                    .onChange(of: eventName, perform: { _ in validateForm() })
                
                TextField("Theme, description, etc!", text: $eventDescription)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .onChange(of: eventDescription, perform: { _ in validateForm() })
                
                locationSearchView().zIndex(1)
                
                HStack {
                    Spacer()
                    if viewModel.timeHasBeenSet {
                        VStack {
                            Text("Starts at \(viewModel.startTime, formatter: DateFormatter.timeFormatter)")
                                .foregroundColor(.white)
                            Button("Change") {
                                viewModel.isShowingSetTimeView = true
                                isShowingSetTimePopup = true
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        }
                        Spacer()
                    } else {
                        Button(action: {
                            isShowingSetTimePopup = true
                        }) {
                            Text("Set Time")
                                .foregroundColor(.black)
                                .bold()
                                .frame(width: 150, height: 50)
                                .background(Color.white)
                                .cornerRadius(30)
                        }
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
                        validateForm()
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
                        validateForm()
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
                        validateForm()
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
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(isFormValid ? Color.white : Color.gray)
                        .cornerRadius(40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 25)
                .disabled(!isFormValid)
            }
            .padding(.horizontal, 16)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
        .overlay(
            Group {
                if isShowingSetTimePopup {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isShowingSetTimePopup = false
                        }
                    
                    SetTime(viewModel: viewModel, isShowingSetTimePopup: $isShowingSetTimePopup)
                        .transition(.scale)
                }
            }
        )
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    @ViewBuilder
    private func locationSearchView() -> some View {
        TextField("Location", text: $viewModelLoc.queryFragment, onEditingChanged: { isEditing in
            if isEditing {
                isLocationSelected = false
            }
        })
        .padding()
        .background(Color.gray)
        .cornerRadius(10)
        .foregroundColor(.white)
        .overlay(
            Group {
                if !viewModelLoc.results.isEmpty && !isLocationSelected {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModelLoc.results, id: \.self) { result in
                                LocationSearchResultCell(title: result.title, subtitle: result.subtitle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 4)
                                    .onTapGesture {
                                        self.location = result.title + ", " + result.subtitle
                                        viewModelLoc.queryFragment = result.title
                                        self.locationTitle = result.title
                                        self.locationSubtitle = result.subtitle
                                        isLocationSelected = true
                                        print("TAPPED")
                                        validateForm()
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
        print("[KB]: ", self.location, ":", self.locationTitle, ":", self.locationSubtitle)
        geocodeAddress(address: location) { coordinate, error in
            if let error = error {
                print("Geocoding error: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Location not found"
                }
                return
            }
            
            if let coordinate = coordinate {
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
                        DispatchQueue.main.async {
                            self.errorMessage = "Error adding event"
                        }
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
    
    private func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let apiKey = "AIzaSyCTECbYPrMRighcsTJ-2on5jU7pckO6mnE"
        print("[KB]\(address)")
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&key=\(apiKey)"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    
                    let specificResult = results.first { result in
                        if let addressComponents = result["address_components"] as? [[String: Any]] {
                            return addressComponents.contains { component in
                                if let types = component["types"] as? [String] {
                                    return types.contains("street_number")
                                }
                                return false
                            }
                        }
                        return false
                    }
                    
                    let resultToUse = specificResult ?? results.first
                    
                    if let geometry = resultToUse?["geometry"] as? [String: Any],
                       let location = geometry["location"] as? [String: Any],
                       let lat = location["lat"] as? Double,
                       let lng = location["lng"] as? Double {
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        completion(coordinate, nil)
                    } else {
                        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]))
                    }
                } else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    private func validateForm() {
        isFormValid = !eventName.isEmpty && !eventDescription.isEmpty && !location.isEmpty && viewModel.timeHasBeenSet && selection != nil
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddEvents_Previews: PreviewProvider {
    static var previews: some View {
        AddEvents()
    }
}
