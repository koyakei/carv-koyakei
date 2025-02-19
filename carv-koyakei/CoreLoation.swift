//
//  CoreLoation.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/19.
//
import Foundation
import CoreLocation
import CoreMotion
class OrientationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    var trueNorthHeading: Double = 0
    var deviceAttitude: CMAttitude?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdates() {
        // 真北の取得開始
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        // デバイス姿勢の監視
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical,
                to: .main) { [weak self] (motion, error) in
                self?.deviceAttitude = motion?.attitude
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                        didUpdateHeading newHeading: CLHeading) {
        trueNorthHeading = newHeading.trueHeading  // 真北基準の方位角[度]
    }
}
