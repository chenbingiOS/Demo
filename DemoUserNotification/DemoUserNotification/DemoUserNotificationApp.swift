//
//  DemoUserNotificationApp.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/8.
//

import SwiftUI

@main
struct DemoUserNotificationApp: App {
    // 通过适配器注入SwiftUI生命周期
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TableView()
        }
    }
}



class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]) { (granted, error) in
            print("是否授权: \(granted)")
            // Enable or disable features based on authorization.
        }
        return true
    }
}

