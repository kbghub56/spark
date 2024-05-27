import UIKit
import Firebase
import SCSDKLoginKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        if SCSDKLoginClient.application(app, open: url, options: options){
            return true
        }
        else{
            return false
        }
    }
    
   
    
    // Add any additional app delegate methods here if needed
}
