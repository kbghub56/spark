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
    @State private var incomingURL: URL?

    var body: some Scene {
        WindowGroup {
            ContentView(incomingURL: $incomingURL)
                .environmentObject(authViewModel)
                .environmentObject(userManager)
                .environmentObject(EventsViewModel(authViewModel: authViewModel))
                .onOpenURL { url in
                    print("RECEIVED \(url)")
                    incomingURL = url
                }
        }
    }
}
