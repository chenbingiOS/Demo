//
//  NotificationManager.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/9.
//

import UIKit
import CoreLocation

class NotificationManager: NSObject, ObservableObject {
    // 发送日期通知
    func scheduleCalendarNotification(at date: Date) {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)

        // 日期类型
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

    // 发送时间线通知
    func scheduleTimeIntervalNotification(at time: Int) {
        // 时间线类型
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)

        // 配置本地通知内容
        let content = UNMutableNotificationContent()
        content.title = "TimeInterval Title"
        content.title = NSString.localizedUserNotificationString(forKey: "TimeInterval Title", arguments: nil)
        content.subtitle = "This is timeInterval subtitle"
        content.body = "This is timeInterval body"
        content.sound = UNNotificationSound.default

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UserNotificationType.timeInterval.rawValue, content: content, trigger: trigger)

        // 本地通知请求写入系统
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("本地通知请求写入失败 \(error)")
            } else {
                print("本地通知请求写入成功 \(request)")
            }
        }
    }
    // 发送时间线通知
    func scheduleLocationNotification(at coordinate2D: CLLocationCoordinate2D, radius: Int) {
        // 位置类型
        let region = CLCircularRegion(center: coordinate2D, radius: CLLocationDistance(radius), identifier: "Headquarters")
        region.notifyOnExit = true
        region.notifyOnEntry = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)

        // 配置本地通知内容
        let content = UNMutableNotificationContent()
        content.title = "Location Title"
        content.title = NSString.localizedUserNotificationString(forKey: "location Title", arguments: nil)
        content.subtitle = "This is location subtitle"
        content.body = "This is location body"
        content.sound = UNNotificationSound.default

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UserNotificationType.location.rawValue, content: content, trigger: trigger)

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
