//
//  sparkApp.swift
//  spark
//
//  Created by Kabir Borle on 2/9/24.
//


import SwiftUI

@main
struct SparkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var userManager = UserManager() // Create an instance of UserManager
    @StateObject var eventsViewModel = EventsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userManager) // Add UserManager to the environment
                .environmentObject(eventsViewModel)
        }
    }
}
