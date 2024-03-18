import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var eventsViewModel: EventsViewModel
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var mapState: MapState
    var authViewModel: AuthViewModel
    var userManager: UserManager

    var mapView = MKMapView()
    var friendsLocationsCache: [String: CLLocation] = [:]

    func makeUIView(context: Context) -> MKMapView {
        //locationManager.userManager = userManager
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // Fetch friends' locations initially
        fetchFriendsLocationsIfNeeded()

        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(uiView, with: eventsViewModel.filteredEvents)
        print("updating")
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
                           let longitude = friendData["longitude"] as? Double {
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            DispatchQueue.main.async {
                                // Update or create the annotation for this friend
                                if let annotation = self.mapView.annotations.first(where: { ($0 as? FriendAnnotation)?.title == friendID }) as? FriendAnnotation {
                                    annotation.coordinate = coordinate
                                } else {
                                    let annotation = FriendAnnotation(coordinate: coordinate, title: friendID, subtitle: nil)
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

    


////        //IMPORTANT FOR ZOOM IN WHEN YOU LOG ON
////        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
////                    let region = MKCoordinateRegion(
////                        center: CLLocationCoordinate2D(
////                        latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
////                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
////                    )
////                    parent.mapView.setRegion(region, animated: true)
////        }
//    }
//}


class FriendAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
