//
//  UserNotificationManager.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/9.
//

import UIKit
import CoreLocation

protocol LocationNotificationSchedulerDelegate: UNUserNotificationCenterDelegate {
    /// 当用户拒绝通知权限提示时调用
    func notificationPermissionDenied()
    /// 当用户拒绝位置权限提示时调用
    func locationPermissionDenied()
    /// 通知请求完成时调用
    /// - Parameter error: 添加通知时出现错误（可选）
    func notificationScheduled(error: Error?)
}

class UserNotificationManager: NSObject, ObservableObject {
    
    weak var delegate: LocationNotificationSchedulerDelegate? {
        didSet {
            UNUserNotificationCenter.current().delegate = delegate
        }
    }

    // 发送日期通知
    func scheduleCalendarNotification(at date: Date) {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        // 日期类型
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        // NSString.localizedUserNotificationString(forKey: "Calendar Title", arguments: nil)
        let info = UserNotificationInfo(
            notificationId: UserNotificationType.calendar.rawValue,
            locationId: nil,
            categoryId: UserNotificationCategoryType.calendarCategory.rawValue,
            radius: nil,
            latitude: nil,
            longitude: nil,
            title: "Calendar Title",
            subTitle: "This is calendar subtitle",
            body: "This is calendar body",
            data: nil)
        askForNotificationPermissions(notificationInfo: info, trigger: trigger)
    }
    // 发送时间线通知
    func scheduleTimeIntervalNotification(at time: Int) {
        // 时间线类型
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
        let info = UserNotificationInfo (
            notificationId: UserNotificationType.timeInterval.rawValue,
            locationId: nil,
            categoryId: nil,
            radius: nil,
            latitude: nil,
            longitude: nil,
            title: "TimeInterval Title",
            subTitle: "This is timeInterval subtitle",
            body: "This is timeInterval body",
            data: nil)
        askForNotificationPermissions(notificationInfo: info, trigger: trigger)
    }
    // 发送位置通知
    func scheduleLocationNotification(at coordinate2D: CLLocationCoordinate2D, radius: Int) {
        guard CLLocationManager.locationServicesEnabled() else {
            print("【UserNotificationManager】位置服务不可用")
            return
        }
        let info = UserNotificationInfo (
            notificationId: UserNotificationType.location.rawValue,
            locationId: "Headquarters",
            categoryId: nil,
            radius: Double(radius),
            latitude: coordinate2D.latitude,
            longitude: coordinate2D.longitude,
            title: "Location Title",
            subTitle: "This is location subtitle",
            body: "This is location body",
            data: nil)
        let destRegion = destinationRegion(notificationInfo: info)
        let trigger = UNLocationNotificationTrigger(region: destRegion, repeats: false)
        askForNotificationPermissions(notificationInfo: info, trigger: trigger)
    }
}

extension UserNotificationManager {
    // 发送通知
    func askForNotificationPermissions(notificationInfo: UserNotificationInfo, trigger: UNNotificationTrigger) {
        UNUserNotificationCenter.current().requestAuthorization(options: []) { [weak self] granted, err in
            guard granted else {
                DispatchQueue.main.async {
                    self?.delegate?.notificationPermissionDenied()
                }
                if let error = err {
                    print("【UserNotificationManager】通知权限请求失败 \(error)")
                }
                return
            }
            self?.requestNotification(notificationInfo: notificationInfo, trigger: trigger)
        }
    }
    // 请求通知
    func requestNotification(notificationInfo: UserNotificationInfo, trigger: UNNotificationTrigger) {
        let notification = notificationContent(notificationInfo: notificationInfo)
        let request = UNNotificationRequest(identifier: notificationInfo.notificationId ?? "",
                                            content: notification,
                                            trigger: trigger)
        notificationRequest(by: request)
    }
    // 通知内容
    func notificationContent(notificationInfo: UserNotificationInfo) -> UNMutableNotificationContent {
        let notification = UNMutableNotificationContent()
        notification.title = notificationInfo.title ?? ""
        notification.subtitle = notificationInfo.subTitle ?? ""
        notification.body = notificationInfo.body ?? ""
        notification.sound = UNNotificationSound.default

        if let data = notificationInfo.data {
            notification.userInfo = data
        }
        return notification
    }
    // 发送通知
    func notificationRequest(by request: UNNotificationRequest) {
        // 本地通知请求写入系统
        UNUserNotificationCenter.current().add(request) { [weak self] (error) in
            if let error = error {
                print("【UserNotificationManager】本地通知请求写入失败 \(error)")
            } else {
                print("【UserNotificationManager】本地通知请求写入成功 \(request)")
            }
            DispatchQueue.main.async {
                self?.delegate?.notificationScheduled(error: error)
            }
        }
    }
    // 位置
    func destinationRegion(notificationInfo: UserNotificationInfo) -> CLCircularRegion {
        let destRegion = CLCircularRegion(center: notificationInfo.coordinate2D,
                                          radius: notificationInfo.radius ?? 0,
                                          identifier: notificationInfo.locationId ?? "")
        destRegion.notifyOnEntry = true
        destRegion.notifyOnExit = true
        return destRegion
    }
}

