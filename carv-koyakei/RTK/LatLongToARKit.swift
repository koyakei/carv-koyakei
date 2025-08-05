//
//  LatLongToARKit.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/08/05.
//

import Foundation
import simd
import CoreLocation

struct LatLongToARKit {
    var originalPoint : CLLocation
    // WGS84楕円体パラメータ
    let a: Double = 6378137.0             // 長半径(m)
    let f: Double = 1 / 298.257223563     // 扁 // 離心率^2
    
    var e2: Double {
        get {
            return f * (2 - f)
        }
    }
    // 1. 緯度経度高度 → ECEF座標変換
    private func geodeticToECEF(latitude: Double, longitude: Double, altitude: Double) -> SIMD3<Double> {
        let latRad = latitude * Double.pi / 180
        let lonRad = longitude * Double.pi / 180
        
        let N = a / sqrt(1 - e2 * pow(sin(latRad), 2))
        let x = (N + altitude) * cos(latRad) * cos(lonRad)
        let y = (N + altitude) * cos(latRad) * sin(lonRad)
        let z = (N * (1 - e2) + altitude) * sin(latRad)
        
        return SIMD3<Double>(x, y, z)
    }
    
    // 2. ECEF座標差分 → ENU座標変換
    private func ecefToENU(ecefTarget: SIMD3<Double>, ecefOrigin: SIMD3<Double>, originLat: Double, originLon: Double) -> SIMD3<Double> {
        let latRad = originLat * Double.pi / 180
        let lonRad = originLon * Double.pi / 180
        
        let dx = ecefTarget.x - ecefOrigin.x
        let dy = ecefTarget.y - ecefOrigin.y
        let dz = ecefTarget.z - ecefOrigin.z
        
        // ENU変換行列
        let xEast = -sin(lonRad) * dx + cos(lonRad) * dy
        let yNorth = -sin(latRad) * cos(lonRad) * dx - sin(latRad) * sin(lonRad) * dy + cos(latRad) * dz
        let zUp = cos(latRad) * cos(lonRad) * dx + cos(latRad) * sin(lonRad) * dy + sin(latRad) * dz
        
        return SIMD3<Double>(xEast, yNorth, zUp)
    }
    
    // 3. ARKit世界座標系への変換（x=East, y=Up, z=-North）
    private func enuToARCoordinates(enu: SIMD3<Double>) -> SIMD3<Float> {
        let x = Float(enu.x)
        let y = Float(enu.z) // Up をARKitのY軸へ
        let z = Float(-enu.y) // Northを負のZ軸へ
        
        return SIMD3<Float>(x, y, z)
    }
    
    // 使用例
    func convertGeoToARCoordinates(targetLat: Double, targetLon: Double, targetAlt: Double) -> SIMD3<Float> {
                                       let ecefOrigin = geodeticToECEF(latitude: originalPoint.coordinate.latitude, longitude: originalPoint.coordinate.longitude, altitude: originalPoint.altitude)
        let ecefTarget = geodeticToECEF(latitude: targetLat, longitude: targetLon, altitude: targetAlt)
        let enu = ecefToENU(ecefTarget: ecefTarget, ecefOrigin: ecefOrigin, originLat: originalPoint.coordinate.latitude, originLon: originalPoint.coordinate.longitude)
        let arCoord = enuToARCoordinates(enu: enu)
        return arCoord
    }
    
}
