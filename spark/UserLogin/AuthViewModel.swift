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
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isUserAuthenticated = user != nil
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

