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

        guard let bestAttemptContent = bestAttemptContent,
              let attachmentURLAsString = bestAttemptContent.userInfo["media-url"] as? String,
              let attachmentURL = URL(string: attachmentURLAsString)
        else {
            return
        }

        downloadImageFrom(url: attachmentURL) { attachment in
            if attachment != nil {
                bestAttemptContent.attachments = [attachment!] // 有数据，强制解包
                contentHandler(bestAttemptContent)
            }
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

extension NotificationService {
    private func downloadImageFrom(url: URL, with completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let fileURL = localURL else {
                completionHandler(nil)
                return
            }

            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
            let uniqueURLString = ProcessInfo.processInfo.globallyUniqueString + ".png"
            urlPath = urlPath.appendingPathComponent(uniqueURLString)

            try? FileManager.default.moveItem(at: fileURL, to: urlPath)
            do {
                let attachment = try UNNotificationAttachment(identifier: "picture", url: urlPath)
                completionHandler(attachment)
            } catch {
                completionHandler(nil)
            }
        }
        task.resume()
    }
}
