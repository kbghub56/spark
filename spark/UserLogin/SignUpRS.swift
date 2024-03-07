//
//  SignUpRS.swift
//  spark
//
//  Created by Kabir Borle on 2/29/24.
//

import SwiftUI
struct SignUpView: View {
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var shouldNavigate: Bool = false
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    Text("Sign Up")
                        .font(.system(size: 48)).bold()
                        .foregroundColor(.white)
                        .offset(y: 125)
                    Group {
                        TextField("Name", text: $userName)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                            .offset(y: 125)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                            .offset(y: 125)
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                            .offset(y: 125)
                        SecureField("Confirm Password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .padding(20)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(10)
                            .frame(width: 237.1875)
                            .offset(y: 125)
                    }
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    Button(action: {
                        signUp()
                    }) {
                        Text("Confirm")
                            .font(.system(size: 32)).bold()
                            .foregroundColor(.black)
                            .frame(width: 220, height: 60)
                            .background(Color.white)
                            .cornerRadius(45)
                    }
                    .offset(y: 125)
                    Spacer()
                    // Updated section with Button
                    Button(action: {
                        // Action for button tap
                        print("Navigate to login screen")
                    }) {
                        Text("Already have an account?")
                            .font(.system(size: 24)).bold()
                            .underline()
                            .foregroundColor(.white)
                    }
                    .offset(y: -150)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
            .frame(width: 430, height: 932)
            .background(.black)
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
}
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}


