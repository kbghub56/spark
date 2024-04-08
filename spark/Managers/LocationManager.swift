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
import MapKit

class LocationManager: NSObject, ObservableObject {
    private let userManager: UserManager // Changed from var to let to indicate it's set once and doesn't change
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var isLocationSharingEnabled = true
    @Published var nearbyPlace: String?
    private var lastIdentificationTime: Date?


    // Modified init to accept a UserManager instance
    init(userManager: UserManager) {
        self.userManager = userManager
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
        
        // Check if it's been more than 5 minutes since the last identification
        
        if shouldIdentifyPlace() {
            identifyNearbyPlace(for: location)
            lastIdentificationTime = Date() // Update the last identification time
        }
    }
    
    private func shouldIdentifyPlace() -> Bool {
        guard let lastIdentification = lastIdentificationTime else {
            return true // No identification has been done yet
        }
        let timeInterval = Date().timeIntervalSince(lastIdentification)
        return timeInterval >= 30 // 300 seconds = 5 minutes
    }

    private func updateCurrentUserLocation(location: CLLocation?) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        if let location = location, self.isLocationSharingEnabled {
            // Location sharing is enabled and location is available, update latitude and longitude
            db.collection("users").document(currentUserID).updateData([
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "locationLastUpdated": FieldValue.serverTimestamp(),
                "locationOff": false  // Ensure to set locationOff to false
            ]) { error in
                if let error = error {
                    print("Error updating user location: \(error.localizedDescription)")
                } else {
                    print("User location updated successfully.")
                }
            }
        } else {
            // Location sharing is disabled or location is nil, set latitude and longitude to null
            db.collection("users").document(currentUserID).updateData([
                "latitude": FieldValue.delete(),  // Remove the latitude field
                "longitude": FieldValue.delete(),  // Remove the longitude field
                "locationOff": true  // Ensure to set locationOff to true
            ]) { error in
                if let error = error {
                    print("Error setting user location to null: \(error.localizedDescription)")
                } else {
                    print("User location set to null successfully.")
                }
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
    
    func identifyNearbyPlace(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil else {
                print("Reverse geocoding failed: \(error!.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                // Extracting address components
                var addressParts: [String] = []
                if let subThoroughfare = placemark.subThoroughfare {
                    addressParts.append(subThoroughfare)
                }
                if let thoroughfare = placemark.thoroughfare {
                    addressParts.append(thoroughfare)
                }
                if let locality = placemark.locality {
                    addressParts.append(locality)
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressParts.append(administrativeArea)
                }
                if let postalCode = placemark.postalCode {
                    addressParts.append(postalCode)
                }
                if let country = placemark.country {
                    addressParts.append(country)
                }
                
                let address = addressParts.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.nearbyPlace = !address.isEmpty ? address : "Unknown Address"
                    self.updateCurrentUserNearbyPlace(nearbyPlace: self.nearbyPlace)
                }
            }
        }
    }
    
    private func updateCurrentUserNearbyPlace(nearbyPlace: String?) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let nearbyPlace = nearbyPlace else { return }
        let db = Firestore.firestore()

        db.collection("users").document(currentUserID).updateData([
            "nearbyPlace": nearbyPlace
        ]) { error in
            if let error = error {
                print("Error updating user's nearby place: \(error.localizedDescription)")
            } else {
                print("User's nearby place updated successfully.")
            }
        }
    }



}
