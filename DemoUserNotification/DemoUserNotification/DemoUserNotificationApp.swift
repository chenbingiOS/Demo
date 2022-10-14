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
        // 注册通知
        UserNotificationManager().requestNotificationPermissions()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 接收到 deviceToken
        let token = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }.joined()
        print("Device Token: \(token)")
        // 转发 deviceToken 给后端服务器，能够启用远程通知功能
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("无法注册远程通知失败 \(error)")
        // 禁用远程通知功能
        // 模拟器不可用远程通知
        // 需要在 Signing&Capacities 添加 Push Notifications 功能才能使用，否则提示 Error Domain=NSCocoaErrorDomain Code=3000 "未找到应用程序的“aps-environment”的授权字符串" UserInfo={NSLocalizedDescription=未找到应用程序的“aps-environment”的授权字符串}
    }
}
