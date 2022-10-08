//
//  NotificationHandler.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/8.
//

import UIKit

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


class NotificationHandler: NSObject {

}
