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
    @State private var showingSearchView = false  // New state variable for showing SearchView
    @State private var showingFollowRequestsView = false
    @State private var selectedVisibilityFilter: Event.EventVisibility = .publicEvent
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userManager: UserManager
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()  // Instance of LocationManager
    @StateObject private var mapState = MapState()

    
    var body: some View {
        NavigationView {
                    MapViewRepresentable(eventsViewModel: eventsViewModel,
                                         locationManager: locationManager,
                                         mapState: mapState)
                        .ignoresSafeArea()
                        .navigationBarTitle("Spark", displayMode: .inline)
                        .navigationBarItems(trailing: navigationBarItems)
                        .sheet(isPresented: $showingEventInputView) {
                            EventInputView()
                        }
                        .onAppear {
                            print("SUP CUHSTER")
                            mapViewModel.fetchAndListenForFriendsLocations()
                            eventsViewModel.updateCurrentUserID(authViewModel.currentUserID)
                            eventsViewModel.fetchEvents()
                        }
                }
    }
    
    var navigationBarItems: some View {
            HStack {
                addButton
                logoutButton
                followButton
                unfollowButton
                searchAndFollowButton
                manageFollowRequestsButton
            }
        }

    

    
    var addButton: some View {
        Button(action: {
            showingEventInputView = true
        }) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.horizontal)
                .offset(x: -20)
        }
    }
    
    var logoutButton: some View {
        Button(action: {
            authViewModel.logOut()
        }) {
            Image(systemName: "arrow.backward.circle")
                .imageScale(.large)
        }
    }
    
    var followButton: some View {
        Button("Follow") {
            // Implementation for following a user
        }
    }
    
    var unfollowButton: some View {
        Button("Unfollow") {
            // Assuming you have the ID of the user to unfollow
            let userIdToUnfollow = "user_id_to_unfollow"
            userManager.unfollowUser(currentUserID: userIdToUnfollow, targetUserID: userIdToUnfollow)
        }
    }
    
    var searchAndFollowButton: some View {
        Button("S&F") {
            showingSearchView = true
        }
        .sheet(isPresented: $showingSearchView) {
            SearchView()
                .environmentObject(userManager)
        }
    }
    
    var manageFollowRequestsButton: some View {
        Button("FR") {
            showingFollowRequestsView = true
        }
        .sheet(isPresented: $showingFollowRequestsView) {
            FollowRequestView()
                .environmentObject(userManager)
        }
    }

}

struct HomeMapView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMapView()
    }
}
