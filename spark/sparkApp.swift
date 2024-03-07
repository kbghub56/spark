//
//  sparkApp.swift
//  spark
//
//  Created by Kabir Borle on 2/9/24.
//


import SwiftUI
import FirebaseAuth

@main
struct SparkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var userManager = UserManager()
    // You don't need to initialize eventsViewModel here with the currentUserID

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userManager)
                // Inject the existing authViewModel into eventsViewModel
                .environmentObject(EventsViewModel(authViewModel: authViewModel))
        }
    }
}
