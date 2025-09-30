//
//  RTKData.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/08/05.
//

import Foundation
import CoreLocation
import CoreBluetooth
import Combine

@MainActor
final class RTKPeripheral : NSObject, Identifiable,@MainActor CBPeripheralDelegate , ObservableObject{
    var currentData: CLLocation = CLLocation.init()
    
    @Published var peripheral: CBPeripheral
    @Published var clLocation: CLLocation?
    
    @Published var age: Float? = nil
    var latestRes : String = ""
    private var writeCharacteristic: CBCharacteristic?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }
    
    func makeNMEACommand(fields: [String]) -> String {
        // 先頭 $
        var base = "$" + fields.joined(separator: ",")
        
        // XORチェックサム計算（$は除いて, *の前まで）
        let chars = Array(base)
        var checksum: UInt8 = 0
        for i in 1..<chars.count {
            if let ascii = chars[i].asciiValue {
                checksum ^= ascii
            }
        }
        
        // *XX と CRLF を追加
        base += String(format: "*%02X\r\n", checksum)
        return base
    }
    
    func buildNtripCommand(
        port: Int = 2101,
        username: String = "",
        password: String = "",
        ggaInterval: Int = 1
    ) -> String {
        return makeNMEACommand(fields: [
            "PBIZ",
            "ntripcl",
            "1",
            "ntrip1.bizstation.jp",
            String(port),
            "NEAR-FIXED",
            username,
            password,
            String(ggaInterval)
        ])
    }
    
    
    func buildNetworkCommand(
        type: Int,
        ssid: String,
        password: String,
        fixedAddress: String = "",
        gateway: String = "",
        netmask: String = ""
    ) -> String {
        return makeNMEACommand(fields: [
            "PBIZ",
            "wifi",
            "\(type)",
            ssid,
            password,
            fixedAddress,
            gateway,
            netmask
        ])
    }
    
    func startNtrip(){
        if let characteristic = writeCharacteristic {
            peripheral.writeValue(Data(buildNtripCommand().utf8), for: characteristic, type: .withResponse)
        }
    }
    
    func setWifiSetting(ssid: String, password: String){
        if let characteristic = writeCharacteristic {
            peripheral.writeValue(Data(buildNetworkCommand(type: 1, ssid: ssid, password: password).utf8), for: characteristic, type: .withResponse)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            print("特性発見エラー: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("発見された特性: \(characteristic.uuid)")
        }
    }
    
    func subscribeAttitude() {
        guard let characteristic = findCharacteristic(periferalName: peripheral.name!) else {
            print("Characteristic not found")
            return
        }
        
        // 通知サポートチェックを追加
        guard characteristic.properties.contains(.notify) else {
            print("Characteristic does not support notifications")
            return
        }
        
        self.peripheral.setNotifyValue(true, for: characteristic)
        
        print("Subscribe initiated")
    }
    
    func unsubscribeAttitude() {
        guard let characteristic = findCharacteristic(periferalName: peripheral.name!) else { return }
        peripheral.setNotifyValue(false, for: characteristic)
    }
    
    private func findCharacteristic(periferalName : String) -> CBCharacteristic? {
        guard let service = peripheral.services?.first(where: { $0.peripheral?.name == periferalName }) else {
            print("no service")
            return nil }
        return service.characteristics?.first
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error updating value: \(error.localizedDescription)")
            return
        }
        if let data = characteristic.value {
            clLocation = locationFromNMEA(String(decoding: data, as: UTF8.self))
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        print("peripheral:didUpdateNotificationStateFor: \(characteristic)")
        if let error = error {
            print("error: \(error)")
        }
        print("通知状態更新: \(characteristic.isNotifying ? "有効" : "無効")")
    }
    // NMEA文字列からCLLocationを生成する簡易関数（GGAまたはRMCパース例）
    private func locationFromNMEA(_ nmeaSentence: String) -> CLLocation? {
        let parts = nmeaSentence.components(separatedBy: ",")
        if parts[0].hasSuffix("PBIZR") {
            latestRes = nmeaSentence
            return nil
        }
        guard parts.count > 6, parts[0].hasSuffix("GGA") else {
            return nil
        }
        let latRaw = parts[2]
        let latDirection = parts[3]
        let lonRaw = parts[4]
        let lonDirection = parts[5]
        self.age = Float(parts[13]) ?? self.age
        // 緯度 (DDMM.MMMM) -> (度 + 分/60)
        if let latDegrees = Double(latRaw.prefix(2)), let latMinutes = Double(latRaw.suffix(latRaw.count - 2)),
           let lonDegrees = Double(lonRaw.prefix(3)), let lonMinutes = Double(lonRaw.suffix(lonRaw.count - 3)) {
            var latitude = latDegrees + latMinutes / 60.0
            var longitude = lonDegrees + lonMinutes / 60.0
            
            if latDirection == "S" {
                latitude = -latitude
            }
            if lonDirection == "W" {
                longitude = -longitude
            }
            
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        return nil
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
