//
//  ContentView.swift
//  spark
//
//  Created by Kabir Borle on 2/9/24.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userManager: UserManager
    @State private var isLoading = true  // Indicates if the app is currently loading data
    @State private var showInitFriendsSheet = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()  // Show a progress indicator while loading
            } else {
                if authViewModel.isUserAuthenticated {
                    if userManager.isLocationOff {
                        WhenLocationOff(showingLocationOffView: .constant(true))
                            .environmentObject(userManager)
                            .environmentObject(authViewModel)
                    } else {
                        if authViewModel.loggedInThroughLoginPage || authViewModel.hasBitmoji {
                            HomeMapView()
                        } 
                        else {
                            switch authViewModel.userSignUpProgress {
                            case .initial, .signedUp:
                                LocationQuestion()
                                    .environmentObject(authViewModel)
                            case .bitmoji1:
                                SnapAvatar1()
                            case .bitmojiConnected:
                                SnapAvatar2()
                                    .environmentObject(authViewModel)
                            case .signUpCompleted:
                                HomeMapView()
                                    .fullScreenCover(isPresented: $showInitFriendsSheet) {
                                        InitFriends().environmentObject(userManager)
                                    }
                                    .onAppear {
                                        showInitFriendsSheet = true
                                    }
                            }
                        }
                    }
                } else {
                    SignUpView()
                        .environmentObject(authViewModel)
                }
            }
        }
        .onAppear {
            userManager.fetchUserLocationOffStatus { isLocationOff in
                DispatchQueue.main.async {
                    userManager.isLocationOff = isLocationOff
                    isLoading = false  // Data has been fetched, hide the progress indicator
                }
            }
        }
    }
}
