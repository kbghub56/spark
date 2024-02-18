//
//  AuthViewModel.swift
//  spark
//
//  Created by Kabir Borle on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore


class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated: Bool = Auth.auth().currentUser != nil

    init() {
        let currentUser = Auth.auth().currentUser
        print("Current user at init: \(currentUser?.email ?? "none")")
        self.isUserAuthenticated = currentUser != nil
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("Auth state changed: now \(user != nil ? "signed in as \(user?.email ?? "")" : "not signed in")")

            DispatchQueue.main.async {
                self?.isUserAuthenticated = user != nil
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            self.isUserAuthenticated = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

//extension for following/unfollowing users
extension AuthViewModel {
    func followUser(userIdToFollow: String, userNameToFollow: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid, let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let followData = ["userName": userNameToFollow] // Data to store in the following subcollection
        
        db.collection("Users").document(currentUserId)
            .collection("following").document(userIdToFollow).setData(followData) { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Now add the current user to the other user's followers collection
                let followerData = ["userName": currentUser.displayName ?? "Unknown User"] // Use the display name or another identifier
                
                db.collection("Users").document(userIdToFollow)
                    .collection("followers").document(currentUserId).setData(followerData, completion: completion)
            }
    }


    func unfollowUser(userIdToUnfollow: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("Users").document(currentUserId)
            .collection("following").document(userIdToUnfollow).delete(completion: completion)
        
        // Optionally, remove the current user from the other user's followers collection
        db.collection("Users").document(userIdToUnfollow)
            .collection("followers").document(currentUserId).delete(completion: completion)
    }

    func fetchFollowing(completion: @escaping ([User]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("Users").document(currentUserId).collection("following").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                let users = snapshot?.documents.compactMap {
                    try? $0.data(as: User.self)
                }
                completion(users, nil)
            }
        }
    }
    
    // Search for a user by their email
    func searchUserByEmail(email: String, completion: @escaping (User?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("Users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                let user = snapshot?.documents.compactMap { document -> User? in
                    var user = try? document.data(as: User.self)
                    user?.id = document.documentID  // This should work now that 'id' is mutable
                    return user
                }.first
                completion(user, nil)
            }
        }
    }
    
    // Check if the current user is following another user
    func isUserFollowing(userIdToCheck: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let followingDocRef = db.collection("Users").document(currentUserId)
                                .collection("following").document(userIdToCheck)
        
        followingDocRef.getDocument { document, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(document?.exists ?? false, nil)
            }
        }
    }
}


