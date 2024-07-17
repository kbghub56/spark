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
    @Published var isLocationOff: Bool = false
    @Published var isLocationNoAuth: Bool = false
    
    init() {
            getCurrentUser { [weak self] user in
                DispatchQueue.main.async {
                    self?.currentUser = user
                }
                print("[KB] \(self?.currentUser?.userName)")
                
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
    
    func sendFollowRequest(from currentUserID: String, to targetUserID: String, fromUser fromUsername: String, fromUserDocID fromDocId: String) {
        let db = Firestore.firestore()

        // Fetch the Bitmoji URL of the sender (current user)
        db.collection("users").document(fromDocId).getDocument { [weak self] document, error in
            var bitmojiUrl = ""  // Default to an empty string if the URL can't be fetched

            if let document = document, document.exists, let url = document.data()?["bitmojiUrl"] as? String {
                bitmojiUrl = url  // Update bitmojiUrl if it's available
            } else {
                print("Could not fetch sender's Bitmoji URL or it does not exist.")
            }

            // Create the follow request document using the fetched or default Bitmoji URL
            let followRequest = [
                "from": currentUserID,
                "to": targetUserID,
                "status": "pending",
                "fromUsername": fromUsername,
                "bitmojiUrl": bitmojiUrl  // Use the fetched or default Bitmoji URL
            ]

            // Send the follow request
            db.collection("followRequests").addDocument(data: followRequest) { error in
                if let error = error {
                    print("Error sending follow request: \(error.localizedDescription)")
                } else {
                    print("Follow request sent successfully, Bitmoji URL included.")
                }
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
                                         status: data["status"] as? String ?? "pending",
                                         fromUsername: data["fromUsername"] as? String ?? "",
                                         bitmojiUrl: data["bitmojiUrl"] as? String ?? "")
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
                    var user = try document.data(as: User.self)
                    user.docID = document.documentID
                    DispatchQueue.main.async {
                        self.currentUser = user // Set the currentUser with fetched user data
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
                
                // Update the current user's friends list and remove the friend from blockedUsers
                currentUserRef.updateData([
                    "friends": FieldValue.arrayUnion([friendUID]),
                    "blockedUsers": FieldValue.arrayRemove([friendUID])
                ]) { error in
                    if let error = error {
                        print("Error updating current user's friends list: \(error.localizedDescription)")
                    } else {
                        print("Current user's friends list updated successfully.")
                    }
                }
                
                // Update the friend user's friends list and remove the current user from blockedUsers
                friendUserRef.updateData([
                    "friends": FieldValue.arrayUnion([currentUserUID]),
                    "blockedUsers": FieldValue.arrayRemove([currentUserUID])
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
    func updateUserLocationOffStatus(isLocationOff: Bool) {
        if(isLocationOff){
            self.setLocationToNullForCurrentUser()
        }
        
        self.isLocationOff = isLocationOff
        
        print("USER MANAGER LOCATION IS LOCATION OFF: \(self.isLocationOff)")
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let userDocRef = Firestore.firestore().collection("users").document(userID)

        // Update 'locationOff' property directly
        userDocRef.updateData(["locationOff": isLocationOff]) { err in
            if let err = err {
                print("Error updating location off status: \(err.localizedDescription)")
            } else {
                print("Successfully updated location off status")
                DispatchQueue.main.async {
                    self.isLocationOff = isLocationOff
                }
            }
        }
    }

    
    func fetchUserLocationOffStatus(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)  // Assuming false means location sharing is enabled by default
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let locationOff = document.get("locationOff") as? Bool ?? false
                completion(locationOff)
            } else {
                completion(false)
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
        
        print("FRIENDS DISTANCES BEING UPDATED")

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists,
                  let data = document.data(), let friends = data["friends"] as? [String] else {
                print("Could not fetch friends for the current user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.friendsDistances.removeAll()  // Clear the existing distances

            let group = DispatchGroup()  // Use a DispatchGroup to wait for all friend data to be fetched

            for friendID in friends {
                group.enter()  // Enter the group for each friend
                db.collection("users").document(friendID).getDocument { (friendDoc, error) in
                    defer { group.leave() }  // Ensure the group is left even if there's an early return

                    guard let friendDoc = friendDoc, friendDoc.exists,
                          let friendData = friendDoc.data(),
                          let latitude = friendData["latitude"] as? Double,
                          let longitude = friendData["longitude"] as? Double,
                          let locationLastUpdated = friendData["locationLastUpdated"] as? Timestamp else {
                        print("Could not fetch location for friendID \(friendID): \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    let friendLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = currentLocation.distance(from: friendLocation)  // Distance in meters
                    let bitmojiUrl = friendData["bitmojiUrl"] as? String
                    let lastActive = locationLastUpdated.dateValue()  // Convert Timestamp to Date
                    let nearbyPlace = friendData["nearbyPlace"] as? String

                    let friendDistance = FriendDistance(id: friendID, email: friendData["email"] as? String ?? "Unknown", distance: distance, bitmojiUrl: bitmojiUrl, userName: friendData["userName"] as? String ?? "Unknown", lastActive: lastActive, nearbyPlace: nearbyPlace)
                    self.friendsDistances.append(friendDistance)
                }
            }

            group.notify(queue: .main) {
                // Sort by last active within 8 hours, then by distance
                self.friendsDistances.sort { friend1, friend2 in
                    let eightHoursAgo = Date().addingTimeInterval(-8 * 60 * 60)  // Calculate the time 8 hours ago
                    let friend1Active = friend1.lastActive! > eightHoursAgo
                    let friend2Active = friend2.lastActive! > eightHoursAgo

                    if friend1Active == friend2Active {
                        return friend1.distance < friend2.distance  // If both are equally active, sort by distance
                    } else {
                        return friend1Active && !friend2Active  // Otherwise, prioritize the friend who was active within the last 8 hours
                    }
                }
            }
        }
    }
    
    func removeAsFriend(currentUserUniqueID: String, friendID: String) {
        let db = Firestore.firestore()
        
        // Use `[weak self]` to capture self weakly to avoid retain cycles
        self.getFirebaseUID(uniqueUserID: currentUserUniqueID) { [weak self] currentUserUID in
            guard let self = self, let currentUserUID = currentUserUID else {
                print("Firebase UID for current user not found")
                return
            }
            
                // Now you have both Firebase UIDs, you can update the friends lists
                let currentUserRef = db.collection("users").document(currentUserUID)
                let friendUserRef = db.collection("users").document(friendID)

                currentUserRef.updateData([
                    "friends": FieldValue.arrayRemove([friendID])
                ]) { error in
                    if let error = error {
                        print("Error updating current user's friends list: \(error.localizedDescription)")
                    } else {
                        print("Current user's friends list updated successfully.")
                    }
                }
                
                friendUserRef.updateData([
                    "friends": FieldValue.arrayRemove([currentUserUID])
                ]) { error in
                    if let error = error {
                        print("Error updating friend user's friends list: \(error.localizedDescription)")
                    } else {
                        print("Friend user's friends list updated successfully.")
                    }
                }
            
        }
        DispatchQueue.main.async {
                if let index = self.friendsDistances.firstIndex(where: { $0.id == friendID }) {
                    self.friendsDistances.remove(at: index)
                }
            }
    }
    
    func setLocationToNullForCurrentUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let usersRef = Database.database().reference().child("users").child(userID)
        usersRef.updateChildValues(["latitude": 0, "longitude": 0]) { error, _ in
            if let error = error {
                print("Error setting location to null: \(error.localizedDescription)")
            } else {
                print("Successfully set location to null for user: \(userID)")
            }
        }
    }
    
    func blockUser(currentUserID: String, userToBlockID: String) {
        let db = Firestore.firestore()
        
        // Add the user to block to the current user's blockedUsers array
        db.collection("users").document(currentUserID).updateData([
            "blockedUsers": FieldValue.arrayUnion([userToBlockID])
        ]) { error in
            if let error = error {
                print("Error blocking user: \(error.localizedDescription)")
            } else {
                print("User blocked successfully")
                
                // Remove the blocked user from the current user's friends list
                self.removeAsFriend(currentUserUniqueID: self.currentUser!.uniqueUserID, friendID: userToBlockID)
                
                // Add the current user's ID to the blocked user's blockedUsers array
                db.collection("users").document(userToBlockID).updateData([
                    "blockedUsers": FieldValue.arrayUnion([currentUserID])
                ]) { error in
                    if let error = error {
                        print("Error updating blocked user's blockedUsers: \(error.localizedDescription)")
                    } else {
                        print("Blocked user's blockedUsers updated successfully")
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
    var bitmojiUrl: String?  // Optional Bitmoji URL
    let userName: String
    var lastActive: Date?  // Last active time
    var nearbyPlace: String?
}
