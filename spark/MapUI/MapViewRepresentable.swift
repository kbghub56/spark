import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var eventsViewModel: EventsViewModel
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var mapState: MapState
    @Binding var selectedEvent: EventAnnotation?
    @Binding var selectedFriend: FriendAnnotation?
    @Binding var showMenu: Bool
    @Binding var didSelectUserAnnotation: Bool
    @Binding var region: MKCoordinateRegion
    @Binding var shouldRecenterMap: Bool
    @Binding var initialRegionSet: Bool
    var authViewModel: AuthViewModel
    var userManager: UserManager

    var mapView = MKMapView()
    var friendsLocationsCache: [String: CLLocation] = [:]
    
    init(eventsViewModel: EventsViewModel,
         locationManager: LocationManager,
         mapState: MapState,
         authViewModel: AuthViewModel,
         userManager: UserManager,
         selectedEvent: Binding<EventAnnotation?>,
         selectedFriend: Binding<FriendAnnotation?>,
         showMenu: Binding<Bool>, 
         didSelectUserAnnotation: Binding<Bool>,
         region: Binding<MKCoordinateRegion>,
         shouldRecenterMap: Binding<Bool>,
         initialRegionSet: Binding<Bool>){
        
        self.eventsViewModel = eventsViewModel
        self.locationManager = locationManager
        self.mapState = mapState
        self.authViewModel = authViewModel
        self.userManager = userManager
        self._selectedEvent = selectedEvent
        self._selectedFriend = selectedFriend
        self._showMenu = showMenu
        self._didSelectUserAnnotation = didSelectUserAnnotation
        self._region = region
        self._shouldRecenterMap = shouldRecenterMap
        self._initialRegionSet = initialRegionSet
    }

    func makeUIView(context: Context) -> MKMapView {
        //locationManager.userManager = userManager
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // Fetch friends' locations initially
        fetchFriendsLocationsIfNeeded()
        
        if let currentLocation = locationManager.currentLocation {
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(uiView, with: eventsViewModel.filteredEvents)
        fetchFriendsLocationsIfNeeded()
        
        if shouldRecenterMap {
                if let currentLocation = locationManager.currentLocation {
                    let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                    uiView.setRegion(region, animated: true)
                    DispatchQueue.main.async {
                        shouldRecenterMap = false
                    }
                }
            }
        
//        if shouldRecenterMap {
//                uiView.setRegion(region, animated: true)
//                DispatchQueue.main.async {
//                    shouldRecenterMap = false
//                }
//            }

        if !initialRegionSet {
                if let currentLocation = locationManager.currentLocation {
                    print("Curr loc: \(locationManager.currentLocation)")
                    let initialRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                    uiView.setRegion(initialRegion, animated: false)
                    DispatchQueue.main.async {
                        initialRegionSet = true
                    }
                    print("set init region, \(initialRegion)")
                }
            }
        
        //IMPORTANT FOR ZOOM IN WHEN YOU LOG ON
//        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//                    let region = MKCoordinateRegion(
//                        center: CLLocationCoordinate2D(
//                        latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
//                        latitudinalMeters: 500,
//                                longitudinalMeters: 500
//    //                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//                    )
//            print("region set :D")
//                    mapView.setRegion(region, animated: true)
//        }
    }

    
    func updateAnnotations(_ uiView: MKMapView, with events: [Event]) {
        let currentAnnotations = uiView.annotations.compactMap { $0 as? EventAnnotation }
        let currentEventIDs = Set(currentAnnotations.map { $0.id })
        let newEventIDs = Set(events.map { $0.id })
        
        
        // Remove annotations for events that are no longer present
        for annotation in currentAnnotations where !newEventIDs.contains(annotation.id) {
            uiView.removeAnnotation(annotation)
        }
        
        // Add annotations for new events
        for event in events where !currentEventIDs.contains(event.id) {
            let annotation = EventAnnotation(event: event)
            uiView.addAnnotation(annotation)
        }
    }

    
    func fetchFriendsLocationsIfNeeded() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists, let friends = document.data()?["friends"] as? [String] {
                for friendID in friends {
                    // Set up a listener for each friend's location
                    db.collection("users").document(friendID).addSnapshotListener { (friendDoc, error) in
                        if let friendDoc = friendDoc, friendDoc.exists,
                           let friendData = friendDoc.data(),
                           let latitude = friendData["latitude"] as? Double,
                           let longitude = friendData["longitude"] as? Double,
                           let nearbyPlace = friendData["nearbyPlace"] as? String,
                           let userName = friendData["userName"] as? String,
                           let locationLastUpdated = friendData["locationLastUpdated"] as? Timestamp,
                           let bitmojiUrl = friendData["bitmojiUrl"] as? String {
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            DispatchQueue.main.async {
                                // Update or create the annotation for this friend
                                if let annotation = self.mapView.annotations.first(where: { ($0 as? FriendAnnotation)?.title == friendID }) as? FriendAnnotation {
                                    annotation.coordinate = coordinate
                                } else {
                                    let annotation = FriendAnnotation(coordinate: coordinate, title: friendID, subtitle: nil, nearbyPlace: nearbyPlace, userName: userName, locationLastUpdated: locationLastUpdated.dateValue(), bitmojiUrl: bitmojiUrl)
                                    self.mapView.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist or lacks 'friends' field.")
            }
        }


    }



    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, authViewModel: authViewModel)
    }
    
}
    
class MapState: ObservableObject {
    @Published var friendsLocationsCache: [String: CLLocation] = [:]
}

    



