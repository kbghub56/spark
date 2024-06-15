import UIKit
import Firebase
import SCSDKLoginKit
import GoogleMaps
import UserNotifications
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyCTECbYPrMRighcsTJ-2on5jU7pckO6mnE")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            guard success else {
                print("NOTIFICATION = FAIL")
                return
            }
            print("NOTIFICATION = SUCCESS")
        }
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            print("Firebase token: \(String(describing: fcmToken))")
            
            if let fcmToken = fcmToken {
                // Store the FCM token in Firestore for the current user
                if let currentUser = Auth.auth().currentUser {
                    let db = Firestore.firestore()
                    db.collection("users").document(currentUser.uid).updateData(["fcmToken": fcmToken]) { error in
                        if let error = error {
                            print("Error updating FCM token: \(error)")
                        } else {
                            print("FCM token updated successfully")
                        }
                    }
                }
            }
        }
    
//    @objc func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase token: \(String(describing: fcmToken))")
//    }
//    
//    func messaging(_ messaging: Messaging, didReceiveRegisrtationToken fcmToken: String?) {
//        messaging.token { token, _ in
//            guard let token = token else {
//                return
//            }
//            print("Token: \(token)")
//        }
//    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if SCSDKLoginClient.application(app, open: url, options: options) {
            return true
        } else {
            return false
        }
    }
    
    // Add any additional app delegate methods here if needed
}


