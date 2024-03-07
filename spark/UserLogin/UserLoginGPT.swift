////
////  UserLoginGPT.swift
////  spark
////
////  Created by Kabir Borle on 2/27/24.
////
//
////
////  LoginView.swift
////  spark
////
////  Created by Kabir Borle on 2/14/24.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//struct LoginView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var errorMessage: String?
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @State private var showingSignUp = false
//
//
//    var body: some View {
//        VStack {
//            TextField("Email", text: $email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                .autocapitalization(.none)
//                .keyboardType(.emailAddress)
//
//            SecureField("Password", text: $password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//
//            Button("Log In") {
//                loginUser(email: email, password: password)
//            }
//            .padding()
//            Button("Sign Up") {
//                showingSignUp = true
//            }
//            .padding()
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//        }
//        .sheet(isPresented: $showingSignUp) {
//            SignUpView()
//                .environmentObject(authViewModel)
//        }
//    }
//
//
//    func loginUser(email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//            } else {
//                self.authViewModel.isUserAuthenticated = true
//            }
//        }
//    }
//}
//
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//            .environmentObject(AuthViewModel())
//    }
//}
//
////
////  AuthViewModel.swift
////  spark
////
////  Created by Kabir Borle on 2/14/24.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//import FirebaseFirestoreSwift
//import FirebaseFirestore
//
//
//class AuthViewModel: ObservableObject {
//    @Published var isUserAuthenticated: Bool = Auth.auth().currentUser != nil
//    @Published var currentUserID: String? = Auth.auth().currentUser?.uid  // Add this line
//
//    init() {
//        updateCurrentUser()
//
//        Auth.auth().addStateDidChangeListener { [weak self] _, user in
//            DispatchQueue.main.async {
//                self?.updateCurrentUser()
//            }
//        }
//    }
//
//    private func updateCurrentUser() {
//        let currentUser = Auth.auth().currentUser
//        self.isUserAuthenticated = currentUser != nil
//        self.currentUserID = currentUser?.uid  // Update the current user ID
//        print("Current user at init: \(currentUser?.email ?? "none")")
//        print("Auth state changed: now \(currentUser != nil ? "signed in as \(currentUser?.email ?? "")" : "not signed in")")
//    }
//
//    func logOut() {
//        do {
//            try Auth.auth().signOut()
//            self.isUserAuthenticated = false
//            self.currentUserID = nil  // Clear the current user ID on logout
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//    }
//}
//
////extension for following/unfollowing users
//extension AuthViewModel {
//    func signUpUser(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            guard let user = authResult?.user, error == nil else {
//                print("Error signing up: \(error!.localizedDescription)")
//                return
//            }
//            // Proceed to generate a unique user ID
//            self.assignUniqueUserID(for: user)
//        }
//    }
//
//
//    func assignUniqueUserID(for user: FirebaseAuth.User) {
//        generateUniqueID { uniqueID in
//            guard let uniqueID = uniqueID else {
//                // Handle the case where a unique ID could not be generated
//                return
//            }
//
//            // Match the field names with your User model
//            let userData: [String: Any] = [
//                "email": user.email ?? "",  // Handle optional email
//                "userName": "",  // Decide how you want to handle the userName
//                "uniqueUserID": uniqueID,
//                "friends": []
//            ]
//
//            let db = Firestore.firestore()
//            db.collection("users").document(user.uid).setData(userData) { error in
//                if let error = error {
//                    print("Error saving user data: \(error.localizedDescription)")
//                } else {
//                    print("User data saved successfully.")
//                }
//            }
//        }
//    }
//
//
//    func generateUniqueID(completion: @escaping (String?) -> Void) {
//        let uniqueID = String(format: "%09d", Int(arc4random_uniform(1_000_000_000)))
//        isIDUnique(uniqueID) { isUnique in
//            if isUnique {
//                completion(uniqueID)
//            } else {
//                // Recursively call generateUniqueID until a unique ID is found
//                self.generateUniqueID(completion: completion)
//            }
//        }
//    }
//
//
//    func isIDUnique(_ id: String, completion: @escaping (Bool) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("users").whereField("userID", isEqualTo: id).getDocuments { snapshot, error in
//            if let error = error {
//                print("Error checking ID uniqueness: \(error.localizedDescription)")
//                completion(false)
//            } else {
//                let isUnique = snapshot?.documents.isEmpty ?? false
//                completion(isUnique)
//            }
//        }
//    }
//}
//
//
////
////  SignUpView.swift
////  spark
////
////  Created by Kabir Borle on 2/14/24.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//struct SignUpView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var errorMessage: String?
//    @EnvironmentObject var authViewModel: AuthViewModel  // Ensure AuthViewModel is provided as an environment object
//
//    var body: some View {
//        VStack {
//            TextField("Email", text: $email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                .autocapitalization(.none)
//                .keyboardType(.emailAddress)
//
//            SecureField("Password", text: $password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            SecureField("Confirm Password", text: $confirmPassword)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//
//            Button("Sign Up") {
//                signUp()
//            }
//            .padding()
//        }
//        .padding()
//    }
//
//    func signUp() {
//        guard !email.isEmpty, !password.isEmpty else {
//            self.errorMessage = "Please fill in all fields."
//            return
//        }
//        guard password.count >= 6 else {
//            self.errorMessage = "Password must be at least 6 characters long."
//            return
//        }
//        guard password == confirmPassword else {
//            self.errorMessage = "Passwords do not match."
//            return
//        }
//
//        // Call signUpUser from AuthViewModel
//        authViewModel.signUpUser(email: email, password: password)
//    }
//}
