//
//  AuthViewModel.swift
//  spark
//
//  Created by Kabir Borle on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

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

