//
//  HomeMapView.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//

import SwiftUI

struct HomeMapView: View {
    @StateObject var eventsViewModel = EventsViewModel()
    @State private var showingEventInputView = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userEmailToSearch = ""
    @State private var isFollowing = false
    
    var logoutButton: some View {
        Button("Log Out") {
            authViewModel.logOut()
        }
    }
    
    var body: some View {
        NavigationView {
            MapViewRepresentable(eventsViewModel: eventsViewModel)
                .ignoresSafeArea()
                .navigationBarTitle("Spark", displayMode: .inline)
                .navigationBarItems(trailing: HStack {
                    // Add event button (if you have one)
                    Button(action: {
                        showingEventInputView = true
                    }) {
                        Image(systemName: "plus")
                    }
                    // Sign out button
                    Button(action: {
                        authViewModel.logOut()
                    }) {
                        Image(systemName: "arrow.backward.circle")
                            .imageScale(.large)
                    }
                    followButton
                    unfollowButton
                    searchAndFollowButton
                })
                .sheet(isPresented: $showingEventInputView) {
                    EventInputView()
                }
        }
    }
    
    var followButton: some View {
        Button("Follow") {
            // Assuming you have the ID of the user to follow
            let userIdToFollow = "user_id_to_follow"
            let userNameToFollow = "User Name to Follow"
            authViewModel.followUser(userIdToFollow: userIdToFollow, userNameToFollow: userNameToFollow) { error in
                if let error = error {
                    print("Failed to follow user: \(error)")
                } else {
                    print("Followed user successfully.")
                }
            }
        }
    }

    var unfollowButton: some View {
        Button("Unfollow") {
            // Assuming you have the ID of the user to unfollow
            let userIdToUnfollow = "user_id_to_unfollow"
            authViewModel.unfollowUser(userIdToUnfollow: userIdToUnfollow) { error in
                if let error = error {
                    print("Failed to unfollow user: \(error)")
                } else {
                    print("Unfollowed user successfully.")
                }
            }
        }
    }
    
    var searchAndFollowButton: some View {
        VStack {
            TextField("Enter user email to search", text: $userEmailToSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Search and Follow/Unfollow") {
                authViewModel.searchUserByEmail(email: userEmailToSearch) { user, error in
                    if let user = user {
                        // User found, now check if the current user is following them
                        authViewModel.isUserFollowing(userIdToCheck: user.id) { isFollowing, error in
                            self.isFollowing = isFollowing
                            if isFollowing {
                                // Unfollow if already following
                                authViewModel.unfollowUser(userIdToUnfollow: user.id) { error in
                                    // Handle the result of unfollow action
                                }
                            } else {
                                // Follow if not already following
                                authViewModel.followUser(userIdToFollow: user.id, userNameToFollow: user.userName) { error in
                                    // Handle the result of follow action
                                }
                            }
                        }
                    } else {
                        print("ERROR")
                    }
                }
            }
        }
    }
    
}

struct HomeMapView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMapView()
    }
}
