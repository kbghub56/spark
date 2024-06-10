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
    @State private var isLoading = true
    @State private var showInitFriendsSheet = false
    @State private var showAddFriendView = false
    @State private var foundUser: User?
    @Binding var incomingURL: URL?
    @State private var showMapModal = true

    var body: some View {
        Group {
            if isLoading {
                LandingPage()
            } else {
                if authViewModel.isUserAuthenticated {
                    if userManager.isLocationOff {
                        WhenLocationOff(showingLocationOffView: .constant(true))
                            .environmentObject(userManager)
                            .environmentObject(authViewModel)
                    } else {
                        if authViewModel.loggedInThroughLoginPage || authViewModel.hasBitmoji {
                            HomeMapView()
                        } else {
                            switch authViewModel.userSignUpProgress {
                            case .initial:
                                SignUpView()
                                    .environmentObject(authViewModel)
                            case .signedUp:
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
                    isLoading = false
                }
            }
            handleIncomingURL()
        }
        .onChange(of: incomingURL) { url in
            handleIncomingURL()
        }
        .sheet(isPresented: $showAddFriendView) {
            AddFrTwo(foundUser: foundUser, userManager: userManager, isPresented: $showAddFriendView)
        }
    }

    private func handleIncomingURL() {
        guard let url = incomingURL else { return }
        let pathComponents = url.pathComponents
        if pathComponents.count > 2, pathComponents[1] == "users" {
            let friendCode = pathComponents[2]
            fetchUserWithFriendCode(friendCode)
        }
        incomingURL = nil
    }

    private func fetchUserWithFriendCode(_ code: String) {
        userManager.searchForUser(by: code) { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    foundUser = user
                }
                showAddFriendView = true
            case .failure(let error):
                print("Failed to find user with code: \(error.localizedDescription)")
            }
        }
    }
}
