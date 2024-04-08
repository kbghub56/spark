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
    @State private var navigateToSnapAvatar1: Bool = false
    @State private var navigateToSnapAvatar2 = false
    @State private var navigateToLocationQuestion: Bool = false
    @State private var navigateToInitFriends: Bool = false
    @State private var showInitFriendsSheet = false
    @State private var logInThroughLogin = false


    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()  // Show a progress indicator while loading
            } else {
                if authViewModel.isUserAuthenticated {
                    if userManager.isLocationOff {
                        WhenLocationOff(showingLocationOffView: .constant(true))
                            .environmentObject(userManager)
                    } else {
                        if logInThroughLogin {
                            HomeMapView()
                        }
                        else if navigateToLocationQuestion {
                            LocationQuestion()
                                .environmentObject(authViewModel)
                        }
                        else if navigateToSnapAvatar1 {
                            SnapAvatar1()
                                .environmentObject(authViewModel)
                        } else if navigateToSnapAvatar2 {
                            SnapAvatar2()
                                .environmentObject(authViewModel)
                        } else if navigateToInitFriends {
                            HomeMapView()
                                .fullScreenCover(isPresented: $navigateToInitFriends) {
                                    InitFriends().environmentObject(userManager)
                                }
                        }else {
                            HomeMapView()
                        }
                    }
                } else {
                    SignUpView()
                        .environmentObject(authViewModel)
                        .onReceive(authViewModel.$logInThroughLogin) { shouldNavigate in  // Listen for changes in navigateToSnapAvatar1
                            self.logInThroughLogin = shouldNavigate
                            print("LOGGING IN")
                        }
                        .onReceive(authViewModel.$navigateToLocationQuestion) { shouldNavigate in  // Listen for changes in navigateToSnapAvatar1
                            self.navigateToLocationQuestion = shouldNavigate
                            print("NAVIGATING")
                        }
                }
            }
        }
        .onReceive(authViewModel.$navigateToSnapAvatar1) { newValue in
                navigateToSnapAvatar1 = newValue
            print("NAVIGATING TO SNAP AAVATAR 1")
            if(navigateToSnapAvatar1){
                navigateToLocationQuestion = false
            }
            print("AUTH: \(authViewModel.isUserAuthenticated) , \(navigateToSnapAvatar2)")
            }
        .onReceive(authViewModel.$navigateToSnapAvatar2) { newValue in
                navigateToSnapAvatar2 = newValue
            if(navigateToSnapAvatar2){
                navigateToSnapAvatar1 = false
            }
            print("AUTH: \(authViewModel.isUserAuthenticated) , \(navigateToSnapAvatar2)")
            }
        .onReceive(authViewModel.$navigateToInitFriends) { newValue in
                navigateToInitFriends = newValue
            print("NAVIGATINGTOINITFRIENDSS")
            if(navigateToInitFriends){
                navigateToSnapAvatar2 = false
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
