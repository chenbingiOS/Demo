//
//  LocationView.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/9.
//

import SwiftUI
import CoreLocationUI

struct LocationView: View {
    // 通知类型
    var notificationType: UserNotificationType!
    // 通知管理类
    @ObservedObject var notificationManager = NotificationManager()
    // 位置管理类 // 使用 StateObject，在进入该页面才创建
    @StateObject var locationManager = LocationManager()
    // 半径
    @State var radius: Int = 500

    var body: some View {
        Text(notificationType.title)
            .padding()
        Text("位置发生变更发送本地通知")
            .padding()
        if let coordinate2D = locationManager.coordinate2D {
            Text("Latitude: \(coordinate2D.latitude)")
            Text("Longitude: \(coordinate2D.latitude)")
        }
        HStack {
            Text("半径")
            Text("\(radius)")
            Text("meters")
            Stepper("位置计步器") {
                radius = radius + 100
            } onDecrement: {
                radius = radius - 100
            }
            .labelsHidden()
        }
        .padding()
        Button("发送通知") {
            if let coordinate2D = locationManager.coordinate2D {
                notificationManager.scheduleLocationNotification(at: coordinate2D, radius: radius)
            }
        }
        .padding()
        Text(notificationType.descriptionText)
            .padding()
        LocationButton {
            locationManager.requestLocation()
        }
        .frame(height: 44)
        .padding()
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
