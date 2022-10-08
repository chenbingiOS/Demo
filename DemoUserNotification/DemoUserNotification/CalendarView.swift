//
//  CalendarView.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/8.
//

import SwiftUI

struct CalendarView: View {
    var notificationType: UserNotificationType!
    // 是否显示禁用通知弹窗
    @State var showAlert: Bool = false
    let settingURL = URL(string: UIApplication.openSettingsURLString)!

    var body: some View {
        VStack {
            Text(notificationType.title)
            Text(notificationType.descriptionText)
        }
        .alert("通知已禁用", isPresented: $showAlert) {
            Button("取消") {
                print("取消")
            }
            Button("设置") {
                UIApplication.shared.open(settingURL)
            }
        } message: {
            Text("进入App设置中打开通知")
        }
        .onAppear() {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    showAlert = true
                }
            }
        }
    }
}
