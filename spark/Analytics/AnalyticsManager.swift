//
//  AnalyticsManager.swift
//  spark
//
//  Created by Kabir Borle on 8/21/24.
//

import Firebase

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {
        // Private initializer to ensure singleton usage
    }
    
    private var sessionStartTime: Date?
    
    func setUserID(_ userID: String) {
        Analytics.setUserID(userID)
    }
    
    func setUserProperties(email: String, userName: String) {
        Analytics.setUserProperty(email, forName: "user_email")
        Analytics.setUserProperty(userName, forName: "user_name")
    }
    
    func logAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        sessionStartTime = Date()
    }
    
    func logAppClose() {
        guard let startTime = sessionStartTime else { return }
        let sessionDuration = Date().timeIntervalSince(startTime)
        print("CLOSEd")
        Analytics.logEvent("session_ended", parameters: [
            "duration": sessionDuration
        ])
        sessionStartTime = nil
    }
    
    func logViewProfile(userID: String) {
        Analytics.logEvent("view_profile", parameters: [
            "user_id": userID
        ])
    }
    
    func logUserLogin(userID: String, email: String?) {
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                "user_id": userID,
                "email": email ?? "no_email"
            ])
            print("user logUserLogin")
            setUserID(userID)
            if let email = email {
                setUserProperties(email: email, userName: "")  // You can add username later if available
            }
        }
    
    // Add more custom event logging methods as needed
    
    func enableAnalyticsDebugMode() {
        Analytics.setAnalyticsCollectionEnabled(true)
    }
}
