//
//  NotificationService.swift
//  NotificationService
//
//  Created by mtAdmin on 2022/10/17.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            // 内容修改
            bestAttemptContent.body = "\(bestAttemptContent.body) [新修改内容]"

            let userInfo = bestAttemptContent.userInfo
            let encryptionContent = userInfo["encrypted-content"] as? String
            // 端到端加密
            bestAttemptContent.subtitle = "\(bestAttemptContent.subtitle) \(encryptionContent ?? "")"

            print("触发修改")

            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
