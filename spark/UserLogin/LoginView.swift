//
//  LoginView.swift
//  spark
//
//  Created by Kabir Borle on 2/14/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingSignUp = false


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
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Log In") {
                loginUser(email: email, password: password)
            }
            .padding()
            Button("Sign Up") {
                showingSignUp = true
            }
            .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
                .environmentObject(authViewModel)
        }
    }
    

    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.authViewModel.isUserAuthenticated = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
