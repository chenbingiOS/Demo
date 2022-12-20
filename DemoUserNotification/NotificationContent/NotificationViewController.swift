//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by mtAdmin on 2022/11/9.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet var label: UILabel?

    let imageURLs = ["https://img1.doubanio.com/view/group_topic/l/public/p182017848.jpg",
                     "https://img1.doubanio.com/view/group_topic/l/public/p182017849.jpg",
                     "https://img3.doubanio.com/view/group_topic/l/public/p182017850.jpg",
                     "https://img2.doubanio.com/view/group_topic/l/public/p182017851.jpg",
                     "https://img2.doubanio.com/view/group_topic/l/public/p182017853.jpg"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func didReceive(_ notification: UNNotification) {
        self.label?.text = String("[Content Extension]:\(notification.request.content.body)")
        actionChangeImageButton(self.touchButton)
        self.touchButton.backgroundColor = UIColor.blue
        print("didReceive")
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "changeImage" {
            self.touchButton.backgroundColor = UIColor.yellow
            let random: Int = Int(arc4random() % 5)
            let urlString = imageURLs[0]
            self.label?.text = urlString
            if let url = URL(string: urlString) {
                downloadImageFrom(url: url) {
                    completion(.doNotDismiss)
                }
            }
        } else if response.actionIdentifier == "comment" {
            completion(.dismissAndForwardAction)
        } else {
            completion(.dismiss)
        }
        print("didReceive completionHandler")
    }

    @IBAction func actionChangeImageButton(_ sender: UIButton) {
        let random: Int = Int(arc4random() % 5)
        let urlString = imageURLs[2]
        if let url = URL(string: urlString) {
            downloadImageFrom(url: url) {

            }
        }
    }
}

extension NotificationViewController {
    private func downloadImageFrom(url: URL, completionHandler: @escaping () -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let fileURL = localURL else {
                return
            }

            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
            let uniqueURLString = ProcessInfo.processInfo.globallyUniqueString + ".png"
            urlPath = urlPath.appendingPathComponent(uniqueURLString)

            try? FileManager.default.moveItem(at: fileURL, to: urlPath)

            if let data = try? Data.init(contentsOf: urlPath) {
                self.bgImageView.image = UIImage(data: data)
                self.label?.text = urlPath.absoluteString
            }

            completionHandler()
        }
        task.resume()
    }
}
