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
    @Published var currentUserID: String? = Auth.auth().currentUser?.uid  // Add this line

    init() {
        updateCurrentUser()

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.updateCurrentUser()
            }
        }
    }

    private func updateCurrentUser() {
        let currentUser = Auth.auth().currentUser
        self.isUserAuthenticated = currentUser != nil
        self.currentUserID = currentUser?.uid  // Update the current user ID
        print("Current user at init: \(currentUser?.email ?? "none")")
        print("Auth state changed: now \(currentUser != nil ? "signed in as \(currentUser?.email ?? "")" : "not signed in")")
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            self.isUserAuthenticated = false
            self.currentUserID = nil  // Clear the current user ID on logout
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

//extension for following/unfollowing users
extension AuthViewModel {
    func signUpUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("Error signing up: \(error!.localizedDescription)")
                return
            }
            // Proceed to generate a unique user ID
            self.assignUniqueUserID(for: user)
        }
    }
    
    
    func assignUniqueUserID(for user: FirebaseAuth.User) {
        generateUniqueID { uniqueID in
            guard let uniqueID = uniqueID else {
                // Handle the case where a unique ID could not be generated
                return
            }
            
            // Match the field names with your User model
            let userData: [String: Any] = [
                "email": user.email ?? "",  // Handle optional email
                "userName": "",  // Decide how you want to handle the userName
                "uniqueUserID": uniqueID,
                "friends": []
            ]

            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data saved successfully.")
                }
            }
        }
    }


    func generateUniqueID(completion: @escaping (String?) -> Void) {
        let uniqueID = String(format: "%09d", Int(arc4random_uniform(1_000_000_000)))
        isIDUnique(uniqueID) { isUnique in
            if isUnique {
                completion(uniqueID)
            } else {
                // Recursively call generateUniqueID until a unique ID is found
                self.generateUniqueID(completion: completion)
            }
        }
    }


    func isIDUnique(_ id: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("userID", isEqualTo: id).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking ID uniqueness: \(error.localizedDescription)")
                completion(false)
            } else {
                let isUnique = snapshot?.documents.isEmpty ?? false
                completion(isUnique)
            }
        }
    }
}


