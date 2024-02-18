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
    func followUser(userIdToFollow: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("Users").document(currentUserId)
            .collection("following").document(userIdToFollow).setData([:], completion: completion)
        
        // Optionally, add the current user to the other user's followers collection
        db.collection("Users").document(userIdToFollow)
            .collection("followers").document(currentUserId).setData([:], completion: completion)
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
}


