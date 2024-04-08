//
//  snapLogin1.swift
//  spark
//
//  Created by Kabir Borle on 4/4/24.
//

import SwiftUI
import SCSDKLoginKit
import FirebaseFirestore

struct SnapAvatar1: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Ensure you have this ViewModel to manage authentication state
    @State private var bitmojiUrl: String?
    @State private var navigateToSnapAvatar2 = false
    @State private var showSnapAvatar3 = false  // New state variable for controlling the sheet visibility


    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Sign up with your Snapchat account")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.vertical, 70)
                
                Button(action: {
                    // Initiating the Snapchat login process here
                    SCSDKLoginClient.login(from: nil) { (success: Bool, error: Error?) in
                        if success {
                            print("Login successful")
                            fetchUserData()
                        } else {
                            print("Login failed with error: \(error?.localizedDescription ?? "unknown error")")
                        }
                    }
                }) {
                    HStack {
                        Image("snapchatIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Maintain the aspect ratio while fitting within the frame
                            .frame(height: 40)
                        Text("Continue with Snapchat")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(15)
                }
                Spacer()
            }

//            VStack {
//                Spacer()
//                Button(action: {                   
//                    self.showSnapAvatar3 = true  // Set this to true when the button is tapped
//                }){
//                    Text("I don't have Snapchat")
//                        .underline()
//                        .foregroundColor(.gray)
//                        .padding(.bottom)
//                }
//            }
//            NavigationLink(destination: SnapAvatar2(), isActive: $navigateToSnapAvatar2) {
//                        SnapAvatar2()
//                    }
        }
//        .fullScreenCover(isPresented: $showSnapAvatar3) {  // Use the sheet modifier with the new state variable
//            SnapAvatar3().environmentObject(authViewModel)  // Present SnapAvatar3 in the sheet
//                }
        .onOpenURL { url in
            let handled = SCSDKLoginClient.application(UIApplication.shared, open: url)
            if handled {
                print("Logged in")
            }
        }
        
        if let bitmojiUrl = bitmojiUrl {
            BitmojiView(bitmojiUrl: bitmojiUrl)
                .padding()
        }
    }

    // Function to fetch user data
    func fetchUserData() {
        let builder = SCSDKUserDataQueryBuilder()
            .withDisplayName()
            .withBitmojiTwoDAvatarUrl()
            .withBitmojiAvatarID()
        let userDataQuery = builder.build()

        SCSDKLoginClient.fetchUserData(with: userDataQuery, success: { (userData: SCSDKUserData?, partialError: Error?) in
            if let userData = userData, let bitmojiAvatarURL = userData.bitmojiTwoDAvatarUrl, let bitmojiAvatarID = userData.bitmojiAvatarID {
                DispatchQueue.main.async {
                    self.authViewModel.updateUserBitmoji(bitmojiUrl: bitmojiAvatarURL, bitmojiAvatarId: bitmojiAvatarID)
                    self.navigateToSnapAvatar2 = true
                }
            } else {
                print("No user data available")
            }
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
        })
    }
}

struct SnapAvatar1_Previews: PreviewProvider {
    static var previews: some View {
        SnapAvatar1().environmentObject(AuthViewModel()) // Provide an instance of your AuthViewModel here
    }
}
