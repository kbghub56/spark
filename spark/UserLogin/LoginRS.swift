//
//  LoginRS.swift
//  spark
//
//  Created by Kabir Borle on 3/6/24.
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
    @Environment(\.presentationMode) var presentationMode

//    @State private var name: String = ""
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var shouldNavigate: Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    Text("Log In")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Group {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                        
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                        
                        
                    }
                    
                    Button(action: {
                        loginUser(email: email, password: password)
                        }
                    ) {
                        Text("Confirm")
                            .foregroundColor(.black)
                            .frame(width: 180, height: 60)
                            .background(Color.white)
                            .cornerRadius(45)
                    }
                    Spacer()
                    
                    // Changed to a Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        authViewModel.logInThroughLogin = false
                    }) {
                        Text("Don't have an account?")
                            .font(.system(size: 17))
                            .underline()
                            .foregroundColor(.white)
                    }
                    
                    
                }
                .padding(.vertical, 160)
                .frame(width: 430, height: 932)
                .background(.black)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.slide)
                            .zIndex(1) // Ensure the error message is layered above other content
                            .offset(y: -375) // Adjust this value to position the error message at the desired location
                    }
            }
        }
    }
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.authViewModel.isUserAuthenticated = true
                self.authViewModel.loggedInThroughLoginPage = true
            }
        }
    }
}
struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

