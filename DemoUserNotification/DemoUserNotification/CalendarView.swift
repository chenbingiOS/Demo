//
//  CalendarView.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/8.
//

import SwiftUI

struct CalendarView: View {
    // 通知类型
    var notificationType: UserNotificationType!
    // 是否显示日期选择控件
    @State var wakeUp: Date = Date()
    // 是否显示禁用通知弹窗
    @State var showAlert: Bool = false
    // 跳转设置页面地址
    let settingURL = URL(string: UIApplication.openSettingsURLString)!
    // 通知管理类
    @ObservedObject var notificationManager = UserNotificationManager()

    var body: some View {
        VStack {
            Text(notificationType.title)
                .padding()
            Text("请选择发送通知的时间")
            DatePicker("", selection: $wakeUp, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
            Button("发送通知") {
                notificationManager.scheduleCalendarNotification(at: wakeUp)
            }
            .padding()
            Text(notificationType.descriptionText)
        }
        // 通知
//        .alert("通知已禁用", isPresented: $showAlert) {
//            Button("取消") { print("取消") }
//            Button("设置") { UIApplication.shared.open(settingURL) }
//        } message: {
//            Text("进入App设置中打开通知")
//        }
        // 页面展示后查询通知权限
        .onAppear() {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("权限类型: \(settings)")
                if settings.authorizationStatus != .authorized {
                    showAlert = true
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(notificationType: .calendar)
    }
}
