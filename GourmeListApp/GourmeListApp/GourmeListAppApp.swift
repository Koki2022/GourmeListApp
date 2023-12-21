//
//  GourmeListAppApp.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2023/12/20.
//

import SwiftUI

@main
struct GourmeListAppApp: App {
    // AppDelegateと接続するアダプタを宣言
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
