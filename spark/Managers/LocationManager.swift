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
    private let userManager: UserManager
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var isLocationSharingEnabled = true
    @Published var nearbyPlace: String?
    private var lastIdentificationTime: Date?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationNoAuth: Bool = false

    init(userManager: UserManager) {
        self.userManager = userManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
        requestLocationPermission()
        checkLocationAuthorizationStatus()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    } 
    
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                userManager.isLocationNoAuth = true
                userManager.isLocationOff = false
            case .authorizedAlways, .authorizedWhenInUse:
                userManager.isLocationNoAuth = false
                userManager.isLocationOff = false
            @unknown default:
                userManager.isLocationNoAuth = true
                userManager.isLocationOff = false
            }
        } else {
            userManager.isLocationOff = true
            userManager.isLocationNoAuth = false
        }
    }
    
    func checkIfLocationNoAuth() -> Bool {
            return isLocationNoAuth
        }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        print("user loc set")
        updateCurrentUserLocation(location: location)
        
        if shouldIdentifyPlace() {
            identifyNearbyPlace(for: location)
            lastIdentificationTime = Date()
        }
    }
    
    private func shouldIdentifyPlace() -> Bool {
        guard let lastIdentification = lastIdentificationTime else {
            return true
        }
        let timeInterval = Date().timeIntervalSince(lastIdentification)
        return timeInterval >= 30
    }

    private func updateCurrentUserLocation(location: CLLocation?) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        if let location = location, self.isLocationSharingEnabled {
            db.collection("users").document(currentUserID).updateData([
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "locationLastUpdated": FieldValue.serverTimestamp(),
                "locationOff": false
            ]) { error in
                if let error = error {
                    print("Error updating user location: \(error.localizedDescription)")
                } else {
                    print("User location updated successfully.")
                }
            }
        } else {
            db.collection("users").document(currentUserID).updateData([
                "latitude": FieldValue.delete(),
                "longitude": FieldValue.delete(),
                "locationOff": true
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
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .notDetermined:
            requestLocationPermission()
        case .authorizedWhenInUse:
            requestAlwaysPermission()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            authorizationStatus = manager.authorizationStatus
            isLocationNoAuth = true
            print("is this shit even going thru")
            break
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
