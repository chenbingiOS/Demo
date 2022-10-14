//
//  LocationManager.swift
//  DemoUserNotification
//
//  Created by mtAdmin on 2022/10/9.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    // 位置坐标
    @Published var coordinate2D: CLLocationCoordinate2D?

    override init() {
        super.init()

        manager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        }
    }

    func requestLocation() {
//        manager.requestLocation() // 只请求一次，模拟器位置变更有获取不到的情况
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate2D = manager.location?.coordinate else{
            return
        }
        self.coordinate2D = coordinate2D
        // 位置实时变更
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置获取失败: \(error)")
    }
}
