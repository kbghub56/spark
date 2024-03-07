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
                        .font(.system(size: 48)).bold()
                        .foregroundColor(.white)
                        .offset(y: 125)
                    
                    Group {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                            .offset(y: 125)
                            .foregroundColor(.black)
                        
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                            .offset(y: 125)
                            .foregroundColor(.black)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                        loginUser(email: email, password: password)
                        }
                    ) {
                        Text("Confirm")
                            .font(.system(size: 32)).bold()
                            .foregroundColor(.black)
                            .frame(width: 220, height: 60)
                            .background(Color.white)
                            .cornerRadius(45)
                    }
                    .offset(y: 175)
                    Spacer()
                    
                    // Changed to a Button
                    Button(action: {
                        showingSignUp = true                  }) {
                        Text("Don't have an account yet?")
                            .font(.system(size: 24)).bold()
                            .underline()
                            .foregroundColor(.white)
                    }
                    .offset(y: -275)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
            .offset(y: 80)
            .frame(width: 430, height: 932)
            .background(.black)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
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
struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

