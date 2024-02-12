//
//  AppDelegate.swift
//  spark
//
//  Created by Kabir Borle on 2/12/24.
//


import UIKit
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        return true
    }
    
    // Add any additional app delegate methods here if needed
}
