//
//  SignUpView.swift
//  spark
//
//  Created by Kabir Borle on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SCSDKLoginKit

struct SignUpViewKB: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userName: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel  // Ensure AuthViewModel is provided as an environment object
    
    var body: some View {
        VStack {
            TextField("User Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Sign Up") {
                signUp()
            }
            .padding()
            
            Button("Login with Snapchat") {
                        snapchatLogin()
                    }
                    .padding()
        }
        .padding()
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill in all fields."
            return
        }
        guard password.count >= 6 else {
            self.errorMessage = "Password must be at least 6 characters long."
            return
        }
        guard password == confirmPassword else {
            self.errorMessage = "Passwords do not match."
            return
        }
        
        // Call signUpUser from AuthViewModel
        authViewModel.signUpUser(email: email, password: password, username: userName)
    }
    
    func snapchatLogin() {
        // Ensure this is run on the main thread because it involves UI changes
        DispatchQueue.main.async {
            SCSDKLoginClient.login(from: nil) { success, error in
                if success {
                    print("Successfully logged in to Snapchat.")
                    // You can proceed to fetch the user's Bitmoji here or defer it to another step
                } else {
                    print(error?.localizedDescription ?? "An error occurred during Snapchat login.")
                }
            }
        }
    }
}
