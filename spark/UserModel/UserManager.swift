//
//  UserManager.swift
//  spark
//
//  Created by Kabir Borle on 2/20/24.
//


import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine
import MapKit

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var friendsDistances: [FriendDistance] = []
    
    init() {
            getCurrentUser { [weak self] user in
                DispatchQueue.main.async {
                    self?.currentUser = user
            }
        }
    }

    func followUser(currentUserID: String, targetUserID: String) {
        let db = Firestore.firestore()
        // Add targetUserID to currentUser's following list
        db.collection("users").document(currentUserID).updateData([
            "following": FieldValue.arrayUnion([targetUserID])
        ])
        // Add currentUserID to targetUser's followers list
        db.collection("users").document(targetUserID).updateData([
            "followers": FieldValue.arrayUnion([currentUserID])
        ])
    }

    func unfollowUser(currentUserID: String, targetUserID: String) {
        let db = Firestore.firestore()
        // Remove targetUserID from currentUser's following list
        db.collection("users").document(currentUserID).updateData([
            "following": FieldValue.arrayRemove([targetUserID])
        ])
        // Remove currentUserID from targetUser's followers list
        db.collection("users").document(targetUserID).updateData([
            "followers": FieldValue.arrayRemove([currentUserID])
        ])
    }
    
    func searchForUser(by userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        let db = Firestore.firestore()
        print("Searching for userID: \(userID)")  // Debugging line
        db.collection("users").whereField("uniqueUserID", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error searching for user: \(error.localizedDescription)")  // Debugging line
                completion(.failure(error))
            } else if let document = snapshot?.documents.first {
                print("User document found: \(document.data())")  // Debugging line
                if let foundUser = try? document.data(as: User.self) {
                    completion(.success(foundUser))
                } else {
                    print("Failed to decode user document")  // Debugging line
                    let decodeError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user document"])
                    completion(.failure(decodeError))
                }
            } else {
                print("No user found with ID \(userID)")  // Debugging line
                let noUserError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user found with ID \(userID)"])
                completion(.failure(noUserError))
            }
        }
    }
    
    func sendFollowRequest(from currentUserID: String, to targetUserID: String) {
        let db = Firestore.firestore()
        let followRequest = [
            "from": currentUserID,
            "to": targetUserID,
            "status": "pending"
        ]
        db.collection("followRequests").addDocument(data: followRequest) { error in
            if let error = error {
                print("Error sending follow request: \(error.localizedDescription)")
            } else {
                print("Follow request sent successfully.")
            }
        }
    }
    
    func handleFollowRequest(_ requestID: String, from fromUserID: String, to toUserID: String, approved: Bool) {
        let db = Firestore.firestore()

        if approved {
            // Update the followRequests status to "approved"
            db.collection("followRequests").document(requestID).updateData(["status": "approved"])

            // Mutual addition to each other's 'friends' field or subcollection
            addAsFriend(currentUserUniqueID: fromUserID, friendUniqueID: toUserID)
            addAsFriend(currentUserUniqueID: toUserID, friendUniqueID: fromUserID)
        } else {
            // Update the followRequests status to "rejected" or delete the request
            db.collection("followRequests").document(requestID).updateData(["status": "rejected"])
        }
    }

    func fetchFollowRequests(forUserID userID: String, completion: @escaping ([FollowRequest]) -> Void) {
        let db = Firestore.firestore()
        db.collection("followRequests")
            .whereField("to", isEqualTo: userID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching follow requests: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }

                let requests = documents.map { doc -> FollowRequest in
                    let data = doc.data()
                    return FollowRequest(id: doc.documentID,
                                         fromUserID: data["from"] as? String ?? "",
                                         toUserID: data["to"] as? String ?? "",
                                         status: data["status"] as? String ?? "pending")
                }
                completion(requests)
            }
   
    }
    
    func getCurrentUser(completion: @escaping (User?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    DispatchQueue.main.async {
                        self.currentUser = user // Set the currentUser with fetched user data
                        print(self.currentUser)
                        completion(user)
                    }
                } catch let error {
                    print("Error decoding user: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
    func addAsFriend(currentUserUniqueID: String, friendUniqueID: String) {
        let db = Firestore.firestore()
        
        // Use `[weak self]` to capture self weakly to avoid retain cycles
        self.getFirebaseUID(uniqueUserID: currentUserUniqueID) { [weak self] currentUserUID in
            guard let self = self, let currentUserUID = currentUserUID else {
                print("Firebase UID for current user not found")
                return
            }
            
            // Use `self` explicitly and capture it weakly again
            self.getFirebaseUID(uniqueUserID: friendUniqueID) { [weak self] friendUID in
                guard let self = self, let friendUID = friendUID else {
                    print("Firebase UID for friend user not found")
                    return
                }
                
                // Now you have both Firebase UIDs, you can update the friends lists
                let currentUserRef = db.collection("users").document(currentUserUID)
                let friendUserRef = db.collection("users").document(friendUID)

                currentUserRef.updateData([
                    "friends": FieldValue.arrayUnion([friendUID])
                ]) { error in
                    if let error = error {
                        print("Error updating current user's friends list: \(error.localizedDescription)")
                    } else {
                        print("Current user's friends list updated successfully.")
                    }
                }
                
                friendUserRef.updateData([
                    "friends": FieldValue.arrayUnion([currentUserUID])
                ]) { error in
                    if let error = error {
                        print("Error updating friend user's friends list: \(error.localizedDescription)")
                    } else {
                        print("Friend user's friends list updated successfully.")
                    }
                }
            }
        }
    }


    func getFirebaseUID(uniqueUserID: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("uniqueUserID", isEqualTo: uniqueUserID).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting Firebase UID: \(error.localizedDescription)")
                completion(nil)
            } else if let document = snapshot?.documents.first {
                let uid = document.documentID
                completion(uid)
            } else {
                print("No user found with unique ID \(uniqueUserID)")
                completion(nil)
            }
        }
    }
    
    func updateFriendsDistances(currentLocation: CLLocation) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Current user ID not found.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists,
                  let data = document.data(), let friends = data["friends"] as? [String] else {
                print("Could not fetch friends for the current user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.friendsDistances.removeAll()  // Clear the existing distances

            for friendID in friends {
                db.collection("users").document(friendID).getDocument { (friendDoc, error) in
                    guard let friendDoc = friendDoc, friendDoc.exists,
                          let friendData = friendDoc.data(),
                          let latitude = friendData["latitude"] as? Double,
                          let longitude = friendData["longitude"] as? Double else {
                        print("Could not fetch location for friendID \(friendID): \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    let friendLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = currentLocation.distance(from: friendLocation)  // Distance in meters

                    DispatchQueue.main.async {
                        let friendDistance = FriendDistance(id: friendID, email: friendData["email"] as? String ?? "Unknown", distance: distance)
                        self.friendsDistances.append(friendDistance)
                        self.friendsDistances.sort { $0.distance < $1.distance }  // Sort by distance
                        print("FRIENDS DISTANCES : \(self.friendsDistances)")
                    }
                }
            }
        }
    }


}


struct FriendDistance: Identifiable {
    let id: String  // Friend's userID or a similar unique identifier
    let email: String
    let distance: CLLocationDistance  // Distance in meters
}
