//
//  AppDelegate.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2023/12/20.
//

import Foundation
import UIKit
import GooglePlaces

// APIキーをここに宣言
let API_KEY = "AIzaSyBLE3jJaAlYGO5IrGKlRgDrCi21fjyFrSs"

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        GMSPlacesClient.provideAPIKey("AIzaSyBLE3jJaAlYGO5IrGKlRgDrCi21fjyFrSs")
        return true
    }
}
