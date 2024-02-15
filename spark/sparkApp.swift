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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

