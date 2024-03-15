//
//  MapViewModel.swift
//  spark
//
//  Created by Kabir Borle on 2/23/24.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class MapViewModel: ObservableObject {
    @Published var friendsLocations: [String: CLLocation] = [:]
    private var friendsListeners: [ListenerRegistration] = []
    private let db = Firestore.firestore()

    func fetchAndListenForFriendsLocations() {

        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserID).getDocument { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, document.exists, let userData = document.data(), let friendsIDs = userData["friends"] as? [String] else { return }

            self.listenForFriendsLocations(friendsIDs: friendsIDs)
        }
    }

    private func listenForFriendsLocations(friendsIDs: [String]) {
        for friendID in friendsIDs {
            let listener = db.collection("users").document(friendID)
                .addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let self = self, let document = documentSnapshot, let data = document.data(), let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double else { return }
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    DispatchQueue.main.async {
                        self.friendsLocations[friendID] = location
                    }
                }
            friendsListeners.append(listener)
        }
    }

    deinit {
        for listener in friendsListeners {
            listener.remove()
        }
    }
}

