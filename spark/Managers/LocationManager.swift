//
//  LocationManager.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location // Update the current location
        updateCurrentUserLocation(location: location) // Update Firestore
    }

    private func updateCurrentUserLocation(location: CLLocation) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).updateData([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "locationLastUpdated": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error updating user location: \(error.localizedDescription)")
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Handle case where user has denied the app location access
            break
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
}
