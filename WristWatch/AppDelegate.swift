//
//  AppDelegate.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-29.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let attrs = [
            NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-Medium", size: 22)!
        ]

        UINavigationBar.appearance().titleTextAttributes = attrs
        
        print("Using realm file \(Realm.Configuration().fileURL!)")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
