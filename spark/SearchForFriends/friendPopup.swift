//
//  friendPopup.swift
//  spark
//
//  Created by Kabir Borle on 4/14/24.
//

import SwiftUI

struct FriendPopup: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var isPresented: Bool
    @State private var showRemoveFriendPopup = false

    let friend: FriendAnnotation
    let onTapOutside: () -> Void
    //let onCompletion: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                           .edgesIgnoringSafeArea(.all)
                           .onTapGesture {
                               onTapOutside()
                           }
            
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    profileSection
                    collagesSection
                    removeFriendButton
                }
                .frame(width: 385, height: 450)
                .background(Color.black)
                .cornerRadius(20)
                .shadow(radius: 5)
                // Empty gesture to 'capture' taps without triggering the background's gesture
                .onTapGesture {}
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showRemoveFriendPopup {
                            RemoveFriendPopup(friendID: friend.title!,
                                              friendName: friend.userName ?? "Unknown User",
                                              showPopup: $showRemoveFriendPopup)
                                .environmentObject(userManager)
                        }
            
        }
        .edgesIgnoringSafeArea(.all)
    }
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 25) {
                ZStack{
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 75, height: 75)
                    if let bitmojiUrl = friend.bitmojiUrl, let url = URL(string: bitmojiUrl) {
                        AsyncImage(url: url) { imagePhase in
                            // Handle different states of the image loading process
                            if let image = imagePhase.image {
                                image.resizable() // Make the image resizable
                                    .aspectRatio(contentMode: .fill) // Fill the content in its aspect ratio
                                    .frame(width: 60, height: 60) // Slightly smaller than the white circle for padding
                                    .clipShape(Circle()) // Clip the image to a circle
                            } else if imagePhase.error != nil {
                                Color.gray // Display a gray area in case of an error
                            } else {
                                ProgressView() // Show a progress indicator while loading
                            }
                        }
                    }
                }
               
                VStack(alignment: .leading) {
                    if let username = friend.userName {
                        Text(username).font(.system(size: 28).bold()).foregroundColor(.white)
                            .font(.system(size: 20).bold())
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    } else {
                        Text("Unknown User").font(.system(size: 28).bold()).foregroundColor(.white)
                            .font(.system(size: 20).bold())
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    
                    Text(friend.nearbyPlace ?? "Unknown Place")
                        .font(.system(size: 17).bold())
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 32)
        }
    }

    var collagesSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Collages 📷:")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                Image("PNG image 1")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Image("PNG image 2")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Spacer()
            }
            HStack {
                Spacer()
                Image("PNG image 3")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Image("PNG image")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .cornerRadius(15)
                    .blur(radius: 1.5)
                Spacer()
            }
        }
        .overlay(
            VStack {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .scaleEffect(0.75)
                Text("coming soon ...")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .scaleEffect(0.75)
            }
        ).frame(maxWidth: .infinity)
    }
    var removeFriendButton: some View {
        VStack{
            Spacer()
            Button("Remove Friend") {
                showRemoveFriendPopup = true
//                guard let currentUserUniqueID = userManager.currentUser?.uniqueUserID else {
//                    print("Current user unique ID not found")
//                    return
//                }
//                userManager.removeAsFriend(currentUserUniqueID: currentUserUniqueID, friendID: friend.title!)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(10)
            .padding(.bottom)
            .padding(.horizontal, 5)
            .background(Color.black)
            .cornerRadius(50)
        }.frame(maxWidth: .infinity)
    }
}
