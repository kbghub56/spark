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
            authViewModel.followUser(userIdToFollow: userIdToFollow) { error in
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
    
}

struct HomeMapView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMapView()
    }
}
