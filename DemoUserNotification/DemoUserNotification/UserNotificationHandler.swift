//
//  NotificationHandler.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/8.
//

import UIKit
import CoreLocation

enum UserNotificationType: String {
    case calendar
    case timeInterval
    case location
    case customUI

    var descriptionText: String {
        switch self {
        case .calendar:
            return "需要切换到后台才能接收通知"
        case .timeInterval:
            return "可以接收应用程序是否在前台或后台运行的通知"
        case .location:
            return "可以接收应用程序是否在前台或后台运行的通知"
        default:
            return rawValue
        }
    }

    var title: String {
        switch self {
        case .calendar:     return "Calendar"
        case .timeInterval: return "TimeInterval"
        case .location:     return "Location"
        default: return rawValue
        }
    }
}

enum UserNotificationCategoryType: String {
    case calendarCategory
    case customUICategory
}
// 日历类别交互类别行为
enum CalendarCategoryAction: String {
    case markAsCompleted
    case remindMeIn1Minute
    case remindMeIn5Minutes
}

struct UserNotificationInfo {
    // ID
    let notificationId: String?
    let locationId: String?
    let categoryId: String?
    // 位置
    let radius: Double?
    let latitude: Double?
    let longitude: Double?
    // 位置坐标
    var coordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude ?? 0,
                                      longitude: longitude ?? 0)
    }
    // 通知信息
    let title: String?
    let subTitle: String?
    let body: String?
    let data: [String: Any]?
}

class UserNotificationHandler: NSObject, UserNotificationManagerSchedulerDelegate {
    /// 当用户拒绝通知权限提示时调用
    func notificationPermissionDenied() {}
    /// 当用户拒绝位置权限提示时调用
    func locationPermissionDenied() {}
    /// 通知请求完成时调用
    /// - Parameter error: 添加通知时出现错误（可选）
    func notificationScheduled(error: Error?) {}
    // 如果通知到达时您的应用程序位于前台，共享用户通知中心将调用此方法将通知直接传递到您的应用
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 类别
        guard let notificationType = UserNotificationType(rawValue: notification.request.identifier) else {
            completionHandler([])
            return
        }
        // 可以有的响应方式
        let options: UNNotificationPresentationOptions
        switch notificationType {
        case .calendar:
            options = []
        default:
            options = [.alert, .sound] // 应用内显示通知 .badge 不需要
        }
        completionHandler(options)
    }
    // app处于后台、未运行时，系统会调用该方法，使用此方法处理用户对通知的响应
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("【UserNotificationHandler】默认行为触发")
        } else if (response.actionIdentifier == UNNotificationDismissActionIdentifier) {
            print("【UserNotificationHandler】消失行为触发")
        } else if let category = UserNotificationCategoryType(rawValue: response.notification.request.content.categoryIdentifier) {
            switch category {
            case .calendarCategory:
                handleCalendarCategory(response: response)
            case .customUICategory:
                handleCustomUICategory(response: response)
            }
        }
        // app角标
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    // 通知事件执行
    private func handleCalendarCategory(response: UNNotificationResponse) {
        if let actionType = CalendarCategoryAction(rawValue: response.actionIdentifier) {
            switch actionType {
            case .markAsCompleted:
                print("【UserNotificationHandler】完成")
                break
            case .remindMeIn1Minute:
                // 1 Minute
                let newDate = Date(timeInterval: 60, since: Date())
                UserNotificationManager().scheduleCalendarNotification(at: newDate, false)
                print("【UserNotificationHandler】1 分钟后发送通知")
            case .remindMeIn5Minutes:
                // 5 Minutes
                let newDate = Date(timeInterval: 60*5, since: Date())
                UserNotificationManager().scheduleCalendarNotification(at: newDate, false)
                print("【UserNotificationHandler】5 分钟后发送通知")
            }
        }
    }
    // 自定义事件执行
    private func handleCustomUICategory(response: UNNotificationResponse) {
//        var text: String = ""
//
//
//        if let actionType = CustomizeUICategoryAction(rawValue: response.actionIdentifier) {
//            switch actionType {
//            case .stop:
//                break;
//
//            case .comment:
//                text = (response as! UNTextInputNotificationResponse).userText
//            }
//        }
//
//        if !text.isEmpty {
//            let alertController = UIAlertController(title: "Comment", message: "You just said:\(text)", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default)
//            alertController.addAction(okAction)
//
//            let viewController = UIApplication.shared.keyWindow?.rootViewController
//            viewController?.present(alertController, animated: true, completion: nil)
//        }
//
//        print(response.actionIdentifier)
    }
}

