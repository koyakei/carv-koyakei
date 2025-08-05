//
//  RTKData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/08/05.
//

import Foundation
import CoreLocation

struct RTKDevise {
    public static let shared: RTKDevise = .init()
    var currentData: CLLocation = CLLocation.init()
    
    mutating func update(_ nmea: String) {
        if let location = self.locationFromNMEA(nmea) {
            self.currentData = location
        }
    }
    
    // NMEA文字列からCLLocationを生成する簡易関数（GGAまたはRMCパース例）
    private func locationFromNMEA(_ nmea: String) -> CLLocation? {
        // NMEAトークンをカンマ区切りで分割
        let tokens = nmea.components(separatedBy: ",")
        guard tokens.count > 6 else {
            return nil
        }
        // GGA例: $GPGGA,hhmmss.ss,ddmm.mmmm,a,dddmm.mmmm,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx
        // RMC例: $GPRMC,hhmmss.ss,A,ddmm.mmmm,a,dddmm.mmmm,a,x.x,x.x,ddmmyy,x.x,a
        let type = tokens[0]
        var latitude: CLLocationDegrees = 0.0
        var longitude: CLLocationDegrees = 0.0
        var altitude: CLLocationDistance = 0.0
        var speed: CLLocationSpeed = 0.0
        var course: CLLocationDirection = 0.0
        var timestamp = Date()
        var valid = false

        if type.contains("GGA") {
            // 緯度
            if let lat = nmeaCoordinateToDegrees(tokens[2]), tokens[3] == "N" || tokens[3] == "S" {
                latitude = (tokens[3] == "N") ? lat : -lat
            } else {
                return nil
            }
            // 経度
            if let lon = nmeaCoordinateToDegrees(tokens[4]), tokens[5] == "E" || tokens[5] == "W" {
                longitude = (tokens[5] == "E") ? lon : -lon
            } else {
                return nil
            }
            // 標高(m)
            if let alt = Double(tokens[9]) {
                altitude = alt
            }
            valid = tokens[6] != "0" // 6th フィールドは位置固定状態（0=no fix）
        } else if type.contains("RMC") {
            // 有効フラグ
            valid = tokens[2] == "A"
            if !valid {
                return nil
            }
            // 緯度
            if let lat = nmeaCoordinateToDegrees(tokens[3]), tokens[4] == "N" || tokens[4] == "S" {
                latitude = (tokens[4] == "N") ? lat : -lat
            } else {
                return nil
            }
            // 経度
            if let lon = nmeaCoordinateToDegrees(tokens[5]), tokens[6] == "E" || tokens[6] == "W" {
                longitude = (tokens[6] == "E") ? lon : -lon
            } else {
                return nil
            }
            // 速度節→m/sに変換（1 knot = 0.514444 m/s）
            if let spd = Double(tokens[7]) {
                speed = spd * 0.514444
            }
            // 進行方向
            if let crs = Double(tokens[8]) {
                course = crs
            }
            // UTC日時をパース（例: hhmmss, ddmmyy）
            let timeStr = tokens[1]
            let dateStr = tokens[9]
            if let dateTime = nmeaDateTimeFromStrings(timeStr: timeStr, dateStr: dateStr) {
                timestamp = dateTime
            }
        } else {
            // 他のタイプは未対応
            return nil
        }

        guard valid else {
            return nil
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate,
                                  altitude: altitude,
                                  horizontalAccuracy: 5.0,
                                  verticalAccuracy: 5.0,
                                  course: course,
                                  speed: speed,
                                  timestamp: timestamp)
        return location
    }

    /// NMEA形式の緯度経度「ddmm.mmmm」を度に変換
    func nmeaCoordinateToDegrees(_ value: String) -> CLLocationDegrees? {
        guard value.count >= 4 else { return nil }
        // ddmm.mmmm を分解
        let index = value.index(value.startIndex, offsetBy: 2)
        let degreesStr = String(value[..<index])
        let minutesStr = String(value[index...])
        if let degrees = Double(degreesStr), let minutes = Double(minutesStr) {
            return degrees + minutes / 60.0
        }
        return nil
    }

    /// NMEA UTC time( hhmmss.ss )とdate ( ddmmyy )からDate生成
    func nmeaDateTimeFromStrings(timeStr: String, dateStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "ddMMyyHHmmss"
        guard timeStr.count >= 6, dateStr.count == 6 else {
            return nil
        }
        let hh = timeStr.prefix(2)
        let mm = timeStr.dropFirst(2).prefix(2)
        let ss = timeStr.dropFirst(4).prefix(2)
        let combined = "\(dateStr)\(hh)\(mm)\(ss)"
        return dateFormatter.date(from: combined)
    }

}
