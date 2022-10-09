//
//  TimelintervalView.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/9.
//

import SwiftUI

/// 时间线通知
struct TimelintervalView: View {
    // 通知类型
    var notificationType: UserNotificationType!
    // 时间长度
    @State var time: Int = 10
    // 通知管理类
    @ObservedObject var notificationManager = UserNotificationManager()

    var body: some View {
        Text(notificationType.title)
            .padding()
        Text("在 \(time) seconds 之后发布本地通知")
        HStack {
            Text("\(time)")
            Text("seconds")
            Stepper("时间计步器") {
                time = time + 1
            } onDecrement: {
                time = time - 1
            }
            .labelsHidden()
        }
        .padding()
        Button("发送通知") {
            notificationManager.scheduleTimeIntervalNotification(at: time)
        }
        .padding()
        Text(notificationType.descriptionText)
    }
}

struct TimelintervalView_Previews: PreviewProvider {
    static var previews: some View {
        TimelintervalView()
    }
}
