////
////  MapUIGPT.swift
////  spark
////
////  Created by Kabir Borle on 2/27/24.
////
//
//import Foundation
//import SwiftUI
//import MapKit
//import FirebaseFirestore
//import FirebaseAuth
//
//struct MapViewRepresentable: UIViewRepresentable {
//    @ObservedObject var eventsViewModel: EventsViewModel
//    @ObservedObject var locationManager: LocationManager
//    @ObservedObject var mapState: MapState
//
//    var mapView = MKMapView()
//    var friendsLocationsCache: [String: CLLocation] = [:]
//
//    func makeUIView(context: Context) -> MKMapView {
//        mapView.delegate = context.coordinator
//        mapView.isRotateEnabled = false
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow
//
//        // Fetch friends' locations initially
//        fetchFriendsLocationsIfNeeded()
//
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        updateAnnotations(uiView)
//        print("updating")
//    }
//
//    func updateAnnotations(_ uiView: MKMapView) {
//        // First, remove existing annotations to start fresh
//        uiView.removeAnnotations(uiView.annotations)
//
//        // Add annotations for friends using the cache
//        for (friendID, location) in friendsLocationsCache {
//            let annotation = MKPointAnnotation()
//            annotation.title = friendID // Update to use friend's name if available
//            annotation.coordinate = location.coordinate
//            uiView.addAnnotation(annotation)
//        }
//
//        // Add annotations for events
//        for event in eventsViewModel.events {
//            let annotation = MKPointAnnotation()
//            annotation.title = event.title
//            annotation.subtitle = event.description
//            annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
//            uiView.addAnnotation(annotation)
//        }
//    }
//
//    func fetchFriendsLocationsIfNeeded() {
//        guard mapState.friendsLocationsCache.isEmpty, let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        let db = Firestore.firestore()
//        db.collection("users").document(currentUserID).getDocument { (document, error) in
//            if let document = document, document.exists, let friends = document.data()?["friends"] as? [String] {
//                for friendID in friends {
//                    db.collection("users").document(friendID).getDocument { (friendDoc, error) in
//                        if let friendDoc = friendDoc, friendDoc.exists,
//                           let friendData = friendDoc.data(),
//                           let latitude = friendData["latitude"] as? Double,
//                           let longitude = friendData["longitude"] as? Double {
//                            let location = CLLocation(latitude: latitude, longitude: longitude)
//                            DispatchQueue.main.async {
//                                    self.mapState.friendsLocationsCache[friendID] = location  // Update the cache through the `MapState` instance
//                                    // Update annotations after updating the cache
//                                    self.updateAnnotations(self.mapView)
//                                }
//                        }
//                    }
//                }
//            } else {
//                print("Document does not exist or lacks 'friends' field.")
//            }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//}
//
//class MapState: ObservableObject {
//    @Published var friendsLocationsCache: [String: CLLocation] = [:]
//}
//
//
//
//////        //IMPORTANT FOR ZOOM IN WHEN YOU LOG ON
//////        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//////                    let region = MKCoordinateRegion(
//////                        center: CLLocationCoordinate2D(
//////                        latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
//////                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//////                    )
//////                    parent.mapView.setRegion(region, animated: true)
//////        }
////    }
////}
////
////  CoordinatorClass.swift
////  spark
////
////  Created by Kabir Borle on 2/25/24.
////
//
//import SwiftUI
//import MapKit
//import FirebaseFirestore
//import FirebaseAuth
//
//
//class Coordinator: NSObject, MKMapViewDelegate {
//    var parent: MapViewRepresentable
//
//    init(_ parent: MapViewRepresentable) {
//        self.parent = parent
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            // Return nil so map view draws "blue dot" for standard user location
//            return nil
//        }
//
//        let identifier = "annotation"
//        var view: MKMarkerAnnotationView
//
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//
//        // Customize the annotation view based on the annotation title
//        if let title = annotation.title as? String, title.contains("Friend") {
//            view.markerTintColor = .green
//            view.glyphImage = UIImage(systemName: "person.fill")
//        } else if let title = annotation.title as? String, title.contains("Event") {
//            view.markerTintColor = .red
//            view.glyphImage = UIImage(systemName: "star.fill")
//        } else {
//            // Default color for any other annotations
//            view.markerTintColor = .purple
//        }
//
//        return view
//    }
//
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        // Handle annotation selection for more interaction
//        // For example, you could present a detail view of the event or friend
//    }
//
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        // Handle annotation deselection if needed
//    }
//}
////
////  HomeMapView.swift
////  spark
////
////  Created by Kabir Borle on 2/12/24.
////
//
//import SwiftUI
//
//
//
//struct HomeMapView: View {
//    @StateObject var eventsViewModel = EventsViewModel()
//    @State private var showingEventInputView = false
//    @State private var showingSearchView = false  // New state variable for showing SearchView
//    @State private var showingFollowRequestsView = false
//    @State private var selectedVisibilityFilter: Event.EventVisibility = .publicEvent
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @EnvironmentObject var userManager: UserManager
//    @StateObject private var mapViewModel = MapViewModel()
//    @StateObject private var locationManager = LocationManager()  // Instance of LocationManager
//    @StateObject private var mapState = MapState()
//
//
//    var body: some View {
//        NavigationView {
//                    MapViewRepresentable(eventsViewModel: eventsViewModel,
//                                         locationManager: locationManager,
//                                         mapState: mapState)
//                        .ignoresSafeArea()
//                        .navigationBarTitle("Spark", displayMode: .inline)
//                        .navigationBarItems(trailing: navigationBarItems)
//                        .sheet(isPresented: $showingEventInputView) {
//                            EventInputView()
//                        }
//                        .onAppear {
//                            print("SUP CUHSTER")
//                            mapViewModel.fetchAndListenForFriendsLocations()
//                            eventsViewModel.updateCurrentUserID(authViewModel.currentUserID)
//                            eventsViewModel.fetchEvents()
//                        }
//                }
//    }
//
//    var navigationBarItems: some View {
//            HStack {
//                addButton
//                logoutButton
//                followButton
//                unfollowButton
//                searchAndFollowButton
//                manageFollowRequestsButton
//            }
//        }
//
//
//
//
//    var addButton: some View {
//        Button(action: {
//            showingEventInputView = true
//        }) {
//            Image(systemName: "plus")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 24, height: 24)
//                .padding(.horizontal)
//                .offset(x: -20)
//        }
//    }
//
//    var logoutButton: some View {
//        Button(action: {
//            authViewModel.logOut()
//        }) {
//            Image(systemName: "arrow.backward.circle")
//                .imageScale(.large)
//        }
//    }
//
//    var followButton: some View {
//        Button("Follow") {
//            // Implementation for following a user
//        }
//    }
//
//    var unfollowButton: some View {
//        Button("Unfollow") {
//            // Assuming you have the ID of the user to unfollow
//            let userIdToUnfollow = "user_id_to_unfollow"
//            userManager.unfollowUser(currentUserID: userIdToUnfollow, targetUserID: userIdToUnfollow)
//        }
//    }
//
//    var searchAndFollowButton: some View {
//        Button("S&F") {
//            showingSearchView = true
//        }
//        .sheet(isPresented: $showingSearchView) {
//            SearchView()
//                .environmentObject(userManager)
//        }
//    }
//
//    var manageFollowRequestsButton: some View {
//        Button("FR") {
//            showingFollowRequestsView = true
//        }
//        .sheet(isPresented: $showingFollowRequestsView) {
//            FollowRequestView()
//                .environmentObject(userManager)
//        }
//    }
//
//}
//
//struct HomeMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeMapView()
//    }
//}
//
////
////  MapViewModel.swift
////  spark
////
////  Created by Kabir Borle on 2/23/24.
////
//
//import Foundation
//import CoreLocation
//import FirebaseFirestore
//import FirebaseAuth
//
//class MapViewModel: ObservableObject {
//    @Published var friendsLocations: [String: CLLocation] = [:]
//    private var friendsListeners: [ListenerRegistration] = []
//    private let db = Firestore.firestore()
//
//    func fetchAndListenForFriendsLocations() {
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("users").document(currentUserID).getDocument { [weak self] documentSnapshot, error in
//            guard let self = self, let document = documentSnapshot, document.exists, let userData = document.data(), let friendsIDs = userData["friends"] as? [String] else { return }
//
//            self.listenForFriendsLocations(friendsIDs: friendsIDs)
//        }
//    }
//
//    private func listenForFriendsLocations(friendsIDs: [String]) {
//        for friendID in friendsIDs {
//            let listener = db.collection("users").document(friendID)
//                .addSnapshotListener { [weak self] documentSnapshot, error in
//                    guard let self = self, let document = documentSnapshot, let data = document.data(), let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double else { return }
//                    let location = CLLocation(latitude: latitude, longitude: longitude)
//                    DispatchQueue.main.async {
//                        self.friendsLocations[friendID] = location
//                    }
//                }
//            friendsListeners.append(listener)
//        }
//    }
//
//    deinit {
//        for listener in friendsListeners {
//            listener.remove()
//        }
//    }
//}
//
