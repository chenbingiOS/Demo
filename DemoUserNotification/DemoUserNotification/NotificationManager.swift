//
//  NotificationManager.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/9.
//

import UIKit

class NotificationManager: ObservableObject {
    // 发送通知
    func scheduleNotification(at date: Date) {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)

        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)

        // 配置本地通知内容
        let content = UNMutableNotificationContent()
        content.title = "Calendar Title"
        content.title = NSString.localizedUserNotificationString(forKey: "Calendar Title", arguments: nil)
        content.subtitle = "This is calendar subtitle"
        content.body = "This is calendar body"
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = UserNotificationCategoryType.calendarCategory.rawValue

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UserNotificationType.calendar.rawValue, content: content, trigger: trigger)

        // 本地通知请求写入系统
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("本地通知请求写入失败 \(error)")
            } else {
                print("本地通知请求写入成功 \(request)")
            }
        }
    }
}
