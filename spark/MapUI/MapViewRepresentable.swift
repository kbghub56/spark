import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var eventsViewModel: EventsViewModel
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var mapState: MapState

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
        updateAnnotations(uiView)
        print("updating")
    }
    
    func updateAnnotations(_ uiView: MKMapView) {
        // First, remove existing annotations to start fresh
        uiView.removeAnnotations(uiView.annotations)

        // Add annotations for friends using the cache
        for (friendID, location) in friendsLocationsCache {
            let annotation = MKPointAnnotation()
            annotation.title = friendID // Update to use friend's name if available
            annotation.coordinate = location.coordinate
            uiView.addAnnotation(annotation)
        }

        // Add annotations for events
        for event in eventsViewModel.events {
            let annotation = MKPointAnnotation()
            annotation.title = event.title
            annotation.subtitle = event.description
            annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            uiView.addAnnotation(annotation)
        }
    }
    
    func fetchFriendsLocationsIfNeeded() {
        guard mapState.friendsLocationsCache.isEmpty, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
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
                                    self.mapState.friendsLocationsCache[friendID] = location  // Update the cache through the `MapState` instance
                                    // Update annotations after updating the cache
                                    self.updateAnnotations(self.mapView)
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
        Coordinator(self)
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
