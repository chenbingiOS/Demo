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
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (granted, error) in
            print("Permission granted:\(granted)")
            // Enable or disable features based on authorization.
        }
        return true
    }
}

