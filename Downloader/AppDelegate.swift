//
//  AppDelegate.swift
//  Downloader
//
//  Created by oren shalev on 16/10/2023.
//

import UIKit
import FirebaseCore
import FirebaseInstallations
import FirebaseRemoteConfig

import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Use Firebase library to configure APIs.
            FirebaseApp.configure()

           // Initialize the Google Mobile Ads SDK.
            GADMobileAds.sharedInstance().start(completionHandler: nil)

            Installations.installations().authTokenForcingRefresh(true, completion: { (result, error) in
              if let error = error {
                print("Error fetching token: \(error)")
                return
              }
              guard let result = result else { return }
              print("Installation auth token: \(result.authToken)")
            })
        
            RemoteConfig.remoteConfig().setDefaults(fromPlist: "remote_config_defaults")

            InterstitialAd.manager.loadInterstitialAd()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

