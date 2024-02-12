//
//  sparkApp.swift
//  spark
//
//  Created by Kabir Borle on 2/9/24.
//


import SwiftUI

@main
struct SparkApp: App {
    // Register app delegate for Firebase setup and other app-wide configurations
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView() // Your app's starting view
        }
    }
}
