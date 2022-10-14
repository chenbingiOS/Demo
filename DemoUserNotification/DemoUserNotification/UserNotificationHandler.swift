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

class UserNotificationHandler: NSObject {

}

