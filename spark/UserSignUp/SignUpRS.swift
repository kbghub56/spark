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
//        VStack {
          //  ScrollView {
                ZStack {
                    VStack(spacing: 40) {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Group {
                            HStack {
                                TextField("Name", text: $userName)
                                    .foregroundColor(.black)
                                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                    .background(.gray)
                                    .cornerRadius(15)
                            }
                            
                            HStack {
                                TextField("Email", text: $email)
                                    .foregroundColor(.black)
                                    .autocapitalization(.none)
                                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                    .background(.gray)
                                    .cornerRadius(15)
                            }
                            
                            SecureField("Password", text: $password)
                                .foregroundColor(.black)
                                .autocapitalization(.none)
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                .background(.gray)
                                .cornerRadius(15)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .foregroundColor(.black)
                                .autocapitalization(.none)
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                .background(.gray)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 16)
                        
                        Button(action: {
                            signUp()
                        }) {
                            Text("Confirm")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(.white)
                                .cornerRadius(40)
                        }
                        .padding(.top, 25)
                        .padding(.horizontal, 16)
                        
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
                            .zIndex(1)
                            .offset(y: -375)
                    }
                }
                .fullScreenCover(isPresented: $showingLogIn) {
                    LoginView()
                        .environmentObject(authViewModel)
                }
//            }
//            .background(.black)
//            .ignoresSafeArea(.keyboard)
//        }
    }
    
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
        
        authViewModel.signUpUser(email: email, password: password, username: userName) { success in
            if success {
                self.navigateToSnapAvatar = true
            }
            else {
                DispatchQueue.main.async {
                               self.errorMessage = "Please enter a valid Rice email."
                           }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
