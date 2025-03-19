//
//  GourmeListApp.swift
//  GourmeListApp
//
//  Created by 高橋昴希 on 2023/12/20.
//

import SwiftUI

@main
struct GourmeListApp: App {
    // AppDelegateと接続するアダプタを宣言
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
