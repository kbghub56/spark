//
//  LoginWithSwift.swift
//  spark
//
//  Created by Kabir Borle on 3/25/24.
//

import SwiftUI
import SCSDKLoginKit
import FirebaseFirestore

struct SnapchatLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var bitmojiUrl: String?

    var body: some View {
        Button("Login with Snapchat") {
            // This is where the Snapchat login process is initiated
            SCSDKLoginClient.login(from: nil) { (success: Bool, error: Error?) in
                if success {
                    print("Login successful")
                    // Proceed with your app's login flow
                    fetchUserData()
                } else {
                    print("Login failed with error: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
        .onOpenURL { url in
            // This handles the URL that Snapchat returns after the login process
            let handled = SCSDKLoginClient.application(UIApplication.shared, open: url)
            if handled {
                // Successfully handled the URL, which typically means login was successful
                print("Logged in")
            }
        }
        if let bitmojiUrl = bitmojiUrl {
                    BitmojiView(bitmojiUrl: bitmojiUrl)
                        .padding()
                }
    }
    
    func fetchUserData() {
        let builder = SCSDKUserDataQueryBuilder()
            .withDisplayName()
            .withBitmojiTwoDAvatarUrl()
            .withBitmojiAvatarID()// Requesting Bitmoji avatar URL
        let userDataQuery = builder.build()
        
        SCSDKLoginClient.fetchUserData(with: userDataQuery, success: { (userData: SCSDKUserData?, partialError: Error?) in
            if let userData = userData, let bitmojiAvatarURL = userData.bitmojiTwoDAvatarUrl, let bitmojiAvatarID = userData.bitmojiAvatarID {
                DispatchQueue.main.async {
                    self.authViewModel.updateUserBitmoji(bitmojiUrl: bitmojiAvatarURL, bitmojiAvatarId: bitmojiAvatarID)
                }
            }

            else {
                    print("No user data available")
                }
            }, failure: { (error: Error?, isUserLoggedOut: Bool) in
                print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
            })
    }
}

struct BitmojiView: View {
    let bitmojiUrl: String

    var body: some View {
        AsyncImage(url: URL(string: bitmojiUrl)) { image in
            image.resizable()
        } placeholder: {
            ProgressView() // Displays a loader while the image is loading
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100) // Adjust the frame as needed
    }
}
