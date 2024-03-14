import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var eventsViewModel: EventsViewModel
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var mapState: MapState
    var authViewModel: AuthViewModel

    var mapView = MKMapView()
    var friendsLocationsCache: [String: CLLocation] = [:]

    func makeUIView(context: Context) -> MKMapView {
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
                    db.collection("users").document(friendID).getDocument { (friendDoc, error) in
                        if let friendDoc = friendDoc, friendDoc.exists,
                           let friendData = friendDoc.data(),
                           let latitude = friendData["latitude"] as? Double,
                           let longitude = friendData["longitude"] as? Double {
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            DispatchQueue.main.async {
                                // Update the cache with the latest location for each friend
                                self.mapState.friendsLocationsCache[friendID] = location
                                
                                // Update the mapView annotations to reflect the latest friends' locations and filtered events
                                self.updateAnnotations(self.mapView, with: self.eventsViewModel.filteredEvents)
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
