//
//  TableView.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/8.
//

import SwiftUI

struct TableView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink.init("Calendar Notification",
                                        destination: CalendarView(notificationType: .calendar))
                    NavigationLink.init("Time Interval Notification",
                                        destination: TimelintervalView(notificationType: .timeInterval))
                    NavigationLink.init("Location Notification",
                                        destination: LocationView(notificationType: .location))
                } header: {
                    Text("Local Notifications")
                }
            }
        }
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
    }
}
