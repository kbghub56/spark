//
//  SignUpView.swift
//  spark
//
//  Created by Kabir Borle on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel  // Ensure AuthViewModel is provided as an environment object
    
    var body: some View {
        VStack {
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
        authViewModel.signUpUser(email: email, password: password)
    }
}
