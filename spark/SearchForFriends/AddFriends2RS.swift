//
//  AddFriends2RS.swift
//  spark
//
//  Created by Kabir Borle on 2/29/24.
//

import SwiftUI

struct AddFrTwo: View {
    var foundUser: User?
    var userManager: UserManager
    @State private var errorMessage: String?
    @GestureState private var swipeGesture = false
    @Binding var isPresented: Bool // Add this line
    @Environment(\.presentationMode) var presentationMode


    
    var body: some View {
        ZStack {
            VStack(spacing: 80) {
                VStack(spacing: 25) {
                    Text("Send")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                    
                    Text(foundUser?.userName ?? "User Name")
                        .font(.system(size: 22))
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("a friend request")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                }
                
                Text("Keep in mind your friends can see what you're up to - this is for that group chat and those friends.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 64)
                
                Button(action: {
                    followFoundUser()
                    isPresented = false
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(.white)
                .cornerRadius(25)
                .padding(.top, 25)
                .padding(.horizontal, 64)
            }
        }
        .frame(width: 430, height: 932)
        .background(.black)
        .padding(.horizontal, 64)
    }
    
    func followFoundUser() {
        guard let foundUser = foundUser else { return }
        
        userManager.getCurrentUser { currentUser in
            guard let currentUser = currentUser else {
                errorMessage = "Failed to get current user details"
                return
            }
            print("THIS IS WHAT IS SHOWING UP: \(currentUser.docID)")
            userManager.sendFollowRequest(from: currentUser.uniqueUserID, to: foundUser.uniqueUserID, fromUser: currentUser.userName ?? "", fromUserDocID: currentUser.docID ?? "")
            isPresented = false // Dismiss the AddFrTwo view
            presentationMode.wrappedValue.dismiss()


        }
    }
}


