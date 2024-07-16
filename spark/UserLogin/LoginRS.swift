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
    
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 40) {
                        Text("Log In")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Group {
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .foregroundColor(.black)
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                .background(.gray)
                                .cornerRadius(15)
                            
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                                .foregroundColor(.black)
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                .background(.gray)
                                .cornerRadius(15)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            loginUser(email: email, password: password)
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
                    .padding(.horizontal, 48)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(.black)
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.slide)
                            .zIndex(1)
                            .offset(y: -375)
                    }
                }
            }
            .ignoresSafeArea()
    }
    
    func loginUser(email: String, password: String) {
        authViewModel.loginUser(email: email, password: password) { success in
            if success {
                self.authViewModel.isUserAuthenticated = true
                self.authViewModel.loggedInThroughLoginPage = true
            } else {
                self.errorMessage = "User not found"
            }
        }
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
