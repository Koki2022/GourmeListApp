//
//  AppDelegate.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2023/12/20.
//

import Foundation
import UIKit
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        GMSPlacesClient.provideAPIKey(APIKeyConfig.googlePlaceAPIKey)
        return true
    }
}
