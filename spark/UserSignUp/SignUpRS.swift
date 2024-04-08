//
//  SignUpRS.swift
//  spark
//
//  Created by Kabir Borle on 2/29/24.
//

import SwiftUI
import SCSDKLoginKit

struct SignUpView: View {
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var shouldNavigate: Bool = false
    @State private var errorMessage: String?
    @State private var showingLogIn = false
    @State private var navigateToSnapAvatar = false


    @State private var isSnapchatLoggedIn: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    Text("Sign Up")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Group {
                        TextField("Name", text: $userName)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
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

                        SecureField("Confirm Password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                    }
                   
                    Button(action: {
                        signUp()
                    }) {
                        Text("Confirm")
                            .foregroundColor(.black)
                            .frame(width: 120, height: 60)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    Spacer()
                    // Updated section with Button
                    
                  //  Spacer()
                    Button(action: {
                        showingLogIn = true 
                        authViewModel.logInThroughLogin = true
                        print("Navigate to login screen")
                    }) {
                        Text("Already have an account?")
                            .font(.system(size: 17))
                            .underline()
                            .foregroundColor(.white)
                            .padding(40)
                    }
                    
                    
                    
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 120)
                .frame(width: 430, height: 932)
                .background(.black)
                
                if let errorMessage = errorMessage {
                                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.slide)
                        .zIndex(1) // Ensure the error message is layered above other content
                        //.padding(.bottom)
                        .offset(y: -375) // Adjust this value to position the error message at the desired location
                                }
            }
            .fullScreenCover(isPresented: $showingLogIn) {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
//    private func allFieldsAreValid() -> Bool {
//        // Check if all fields are filled and passwords match
//        return !userName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
//    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill in all fields."
            return
        }
        
        guard email.hasSuffix("@rice.edu") else {
                self.errorMessage = "Please enter a valid Rice email."
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
        authViewModel.signUpUser(email: email, password: password, username: userName) { success in
                if success {
                    self.navigateToSnapAvatar = true
                }
            }
    }
    

    
//   Define a function that starts the Snapchat login process
    
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}


