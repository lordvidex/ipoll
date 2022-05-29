//
//  AppDelegate.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseAuth
import FirebaseAuthUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true // for automatic keyboard management
        FirebaseApp.configure()
        NetworkService.configure()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String? else { return false }
         if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
           return true
         }
         // other URL handling goes here.
         return false
    }
    
}
