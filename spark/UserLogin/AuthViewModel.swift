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
    @Published var snapchatDisplayName: String?
    @Published var snapchatBitmojiAvatarUrl: String?
    @Published var snapchatBitmojiAvatarId: String?
    @Published var snapchatBitmojiWalkingUrl: String?
    @Published var friendsBitmojiUrls: [String: String] = [:]  // Dictionary to store friends' Bitmoji URLs
    @Published var friendsBitmojiWalkingUrls: [String: String] = [:]
    @Published var navigateToSnapAvatar1 = false  // Add this property
    @Published var navigateToSnapAvatar2 = false
    @Published var navigateToLocationQuestion = false
    @Published var navigateToInitFriends = false
    @Published var logInThroughLogin = false

    


  //  @Published var sessionTrigger: UUID = UUID()

    init() {
        updateCurrentUser()
        print("INITIALIZING")

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
        if isUserAuthenticated {
            // Fetch the Bitmoji URL if the user is authenticated
            fetchUserDetails()
        } else {
            // Reset the Bitmoji URL if the user is not authenticated
            self.snapchatBitmojiAvatarUrl = nil
            self.friendsBitmojiUrls = [:]  // Reset on logout

        }
        print("Current user at init: \(currentUser?.email ?? "none")")
        print("Auth state changed: now \(currentUser != nil ? "signed in as \(currentUser?.email ?? "")" : "not signed in")")
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            self.isUserAuthenticated = false
            self.currentUserID = nil  // Clear the current user ID on logout
          //  sessionTrigger = UUID() // Update the UUID on logout
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

//extension for following/unfollowing users
extension AuthViewModel {
    func signUpUser(email: String, password: String, username: String, completion: @escaping (Bool) -> Void) {
        self.navigateToLocationQuestion = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("Error signing up: \(error!.localizedDescription)")
                return
            }
            // Proceed to generate a unique user ID
            self.assignUniqueUserID(for: user, username: username) { success in
                if success {
                    print("SUCCESSS")
                    self.navigateToLocationQuestion = true
                   // self.navigateToSnapAvatar1 = true  // Set navigateToSnapAvatar1 to true
                }
                completion(success)
            }
        }
    }
    
    
    func assignUniqueUserID(for user: FirebaseAuth.User, username: String, completion: @escaping (Bool) -> Void) {
        generateUniqueID { uniqueID in
            guard let uniqueID = uniqueID else {
                // Handle the case where a unique ID could not be generated
                return
            }
            
            
            // Match the field names with your User model
            let userData: [String: Any] = [
                "email": user.email ?? "",  // Handle optional email
                "userName": username,  // Decide how you want to handle the userName
                "uniqueUserID": uniqueID,
                "friends": [],
                "docID" : user.uid
            ]

            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("User data saved successfully.")
                    completion(true)
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
    
    func updateUserBitmoji(bitmojiUrl: String, bitmojiAvatarId: String) {
        guard let userId = currentUserID else { return }
        let userDocRef = Firestore.firestore().collection("users").document(userId)
        
        //Construct url for walking bitmoji
        let bitmojiWalkUrl = "https://sdk.bitmoji.com/me/sticker/\(bitmojiAvatarId)/8e540795-8684-4cf1-853c-af2a41ec9abb"

        userDocRef.updateData([
            "bitmojiUrl": bitmojiUrl,
            "bitmojiAvatarId": bitmojiAvatarId,
            "bitmojiWalkingUrl": bitmojiWalkUrl
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                self.snapchatBitmojiAvatarUrl = bitmojiUrl
                // Update a new property for Bitmoji Avatar ID
                self.snapchatBitmojiAvatarId = bitmojiAvatarId
                self.snapchatBitmojiWalkingUrl = bitmojiWalkUrl
                print("Document successfully updated with Bitmoji URL and Avatar ID")
                self.navigateToSnapAvatar2 = true
            }
        }
    }
    
    func updateUserDefaultAvatar(avatarName: String) {
            guard let userId = currentUserID else { return }
            let userDocRef = Firestore.firestore().collection("users").document(userId)
            
            let bitmojiUrl = avatarName
            let bitmojiWalkingUrl = "\(avatarName)Walking"
            
            userDocRef.updateData([
                "bitmojiUrl": bitmojiUrl,
                "bitmojiAvatarId": avatarName,
                "bitmojiWalkingUrl": bitmojiWalkingUrl
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    self.snapchatBitmojiAvatarUrl = bitmojiUrl
                    self.snapchatBitmojiAvatarId = avatarName
                    self.snapchatBitmojiWalkingUrl = bitmojiWalkingUrl
                    print("Document successfully updated with default avatar")
                    self.navigateToInitFriends = true
                }
            }
        }

    
    func fetchUserDetails() {
            guard let userId = currentUserID else { return }
            let userDocRef = Firestore.firestore().collection("users").document(userId)

            userDocRef.getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    self?.snapchatBitmojiAvatarUrl = document.data()?["bitmojiUrl"] as? String
                    // Fetch Bitmoji Avatar ID
                    self?.snapchatBitmojiAvatarId = document.data()?["bitmojiAvatarId"] as? String
                    self?.snapchatBitmojiWalkingUrl = document.data()?["bitmojiWalkingUrl"] as? String
                    print("SNAPCHAT WALKING URL: \(self?.snapchatBitmojiWalkingUrl)")

                    // Fetch friends' IDs
                    if let friendsIds = document.data()?["friends"] as? [String] {
                        self?.fetchFriendsBitmojiUrls(friendsIds: friendsIds)
                    }
                } else {
                    print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    
    func fetchFriendsBitmojiUrls(friendsIds: [String]) {
            let db = Firestore.firestore()

            friendsIds.forEach { friendId in
                let friendDocRef = db.collection("users").document(friendId)

                friendDocRef.getDocument { [weak self] (document, error) in
                    if let document = document, document.exists,
                       let bitmojiUrl = document.data()?["bitmojiUrl"] as? String,
                       let bitmojiWalkingUrl = document.data()?["bitmojiWalkingUrl"] as? String {
                        DispatchQueue.main.async {
                            // Store the regular Bitmoji URL in the original dictionary
                            self?.friendsBitmojiUrls[friendId] = bitmojiUrl
                            // Store the walking Bitmoji URL in the new dictionary
                            self?.friendsBitmojiWalkingUrls[friendId] = bitmojiWalkingUrl
                        }
                    
                    } else {
                        print("Error fetching friend's Bitmoji URLs: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }

}


