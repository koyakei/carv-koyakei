//
//  LocationManager.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/03/27.
//
import CoreLocation
class LocationManager :NSObject{
    let locationManager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        handle()
    }
    func handle () {
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        YawingBeep.shared
    }
}
