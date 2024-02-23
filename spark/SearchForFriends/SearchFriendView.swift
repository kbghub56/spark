//
//  SearchFriendView.swift
//  spark
//
//  Created by Kabir Borle on 2/21/24.
//

import SwiftUI
import FirebaseAuth


struct SearchView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var searchUserID = ""
    @State private var foundUser: User?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("Enter UserID", text: $searchUserID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Search") {
                searchForUser()
            }
            .padding()

            if let user = foundUser {
                Text("User found: \(user.email)")
                Button("Follow") {
                    followFoundUser()
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }

    func searchForUser() {
        userManager.searchForUser(by: searchUserID) { result in
            switch result {
            case .success(let user):
                self.foundUser = user
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.foundUser = nil
            }
        }
    }

    func followFoundUser() {
        guard let foundUser = foundUser else { return }

        userManager.getCurrentUser { currentUser in
            guard let currentUser = currentUser else {
                self.errorMessage = "Failed to get current user details"
                return
            }

            userManager.sendFollowRequest(from: currentUser.uniqueUserID, to: foundUser.uniqueUserID)
        }
    }
}
