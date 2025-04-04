//
//  MotionWriter.swift
//  skiBodyAttitudeTeacheer
//
//  Created by koyanagi on 2021/10/24.
//

import Foundation
import CoreMotion
import Spatial
class CSVExporter {
    var file: FileHandle?
    var filePath: URL?
    var sample: Int = 0
    let startAt : Date = Date.now
    
    func getClassName(myInstance : Any) -> String{
        let mirror = Mirror(reflecting: myInstance)
        if let className = mirror.subjectType as? AnyClass {
            let classNameString = String(describing: className)
            return "\(classNameString)"
        } else{
            return "error"
        }
    }
    
    func structNameExpander(structObject: Any) -> String{
        let mirror = Mirror(reflecting: structObject)
        var labels:[String] = []
        for case let (label?, _) in mirror.children {
            labels.append(label)
        }
        return labels.joined(separator: ",")
    }

    func open(_ filePath: URL) {
        do {
            FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            let file = try FileHandle(forWritingTo: filePath)
            var header = ""
            header += "date_now,"
            header += "left_acceleration_x,"
            header += "left_acceleration_y,"
            header += "left_acceleration_z,"
            header += "left_attitude_pitch,"
            header += "left_attitude_roll,"
            header += "left_attitude_yaw,"
            header += "left_quaternion_x,"
            header += "left_quaternion_y,"
            header += "left_quaternion_z,"
            header += "left_quaternion_w,"
            header += "left_rotation_x,"
            header += "left_rotation_y,"
            header += "left_rotation_z,"
            header += "right_acceleration_x,"
            header += "right_acceleration_y,"
            header += "right_acceleration_z,"
            header += "right_attitude_pitch,"
            header += "right_attitude_roll,"
            header += "right_attitude_yaw,"
            header += "right_quaternion_x,"
            header += "right_quaternion_y,"
            header += "right_quaternion_z,"
            header += "right_quaternion_w,"
            header += "right_rotation_x,"
            header += "right_rotation_y,"
            header += "right_rotation_z,"
            header += "united_quaternion_x,"
            header += "united_quaternion_y,"
            header += "united_quaternion_z,"
            header += "united_quaternion_w,"
            header += "unitedYawingAngle,"
            header += "yawingSide,"
            header += "percentageOfTurn,"
            header += "numberOfTurns,"
            header += "\n"
            file.write(header.data(using: .utf8)!)
            self.file = file
            self.filePath = filePath
        } catch let error {
            print(error)
        }
    }


    func write(_ structObject: Any) {
        let mirror = Mirror(reflecting: structObject)
        var values:[String] = []
        for case let (_, value) in mirror.children {
            values.append(value as? String ?? "cant convert")
        }
        guard let file = self.file else { return }
        var text = ""
        text += values.joined(separator: ",")
        text += "\n"
        file.write(text.data(using: .utf8)!)
        sample += 1
    }
    func write(_ motion: Carv2Data) {
        guard let file = self.file else { return }
        var text = ""
        let format = DateFormatter()
            format.dateFormat = "HH:mm:ss.SSS"
        format.timeZone = .current
        text += "\(format.string(from: Date(timeIntervalSince1970: motion.recordetTime))),"
        text += "\(motion.acceleration.x),"
        text += "\(motion.acceleration.y),"
        text += "\(motion.acceleration.z),"
        text += "\(Angle2D(radians: motion.attitude.eulerAngles(order: .xyz).angles.x).degrees),"
        text += "\(Angle2D(radians: motion.attitude.eulerAngles(order: .xyz).angles.y).degrees),"
        text += "\(Angle2D(radians: motion.attitude.eulerAngles(order: .xyz).angles.z).degrees),"
        text += "\(motion.attitude.vector.x),"
        text += "\(motion.attitude.vector.y),"
        text += "\(motion.attitude.vector.z),"
        text += "\(motion.attitude.vector.w),"
        text += "\(motion.angularVelocity.x),"
        text += "\(motion.angularVelocity.y),"
        text += "\(motion.angularVelocity.z),"
        print(text)
        text += "\n"
        file.write(text.data(using: .utf8)!)
        sample += 1
    }
    
    func write(_ motion: Carv2AnalyzedDataPair) {
        guard let file = self.file else { return }
        var text = ""
        let format = DateFormatter()
            format.dateFormat = "HH:mm:ss.SSS"
        format.timeZone = .current
        text += "\(format.string(from: Date(timeIntervalSince1970: motion.recordetTime))),"
        text += "\(motion.left.acceleration.x),"
        text += "\(motion.left.acceleration.y),"
        text += "\(motion.left.acceleration.z),"
        text += "\(Angle2D(radians: motion.left.attitude.eulerAngles(order: .xyz).angles.x).degrees),"
        text += "\(Angle2D(radians: motion.left.attitude.eulerAngles(order: .xyz).angles.y).degrees),"
        text += "\(Angle2D(radians: motion.left.attitude.eulerAngles(order: .xyz).angles.z).degrees),"
        text += "\(motion.left.attitude.vector.x),"
        text += "\(motion.left.attitude.vector.y),"
        text += "\(motion.left.attitude.vector.z),"
        text += "\(motion.left.attitude.vector.w),"
        text += "\(motion.left.angularVelocity.x),"
        text += "\(motion.left.angularVelocity.y),"
        text += "\(motion.left.angularVelocity.z),"
        text += "\(motion.right.acceleration.x),"
        text += "\(motion.right.acceleration.y),"
        text += "\(motion.right.acceleration.z),"
        text += "\(Angle2D(radians: motion.right.attitude.eulerAngles(order: .xyz).angles.x).degrees),"
        text += "\(Angle2D(radians: motion.right.attitude.eulerAngles(order: .xyz).angles.y).degrees),"
        text += "\(Angle2D(radians: motion.right.attitude.eulerAngles(order: .xyz).angles.z).degrees),"
        text += "\(motion.right.attitude.vector.x),"
        text += "\(motion.right.attitude.vector.y),"
        text += "\(motion.right.attitude.vector.z),"
        text += "\(motion.right.attitude.vector.w),"
        text += "\(motion.right.angularVelocity.x),"
        text += "\(motion.right.angularVelocity.y),"
        text += "\(motion.right.angularVelocity.z),"
        text += "\(motion.unitedAttitude.vector.x),"
        text += "\(motion.unitedAttitude.vector.y),"
        text += "\(motion.unitedAttitude.vector.z),"
        text += "\(motion.unitedAttitude.vector.w),"
        text += "\(motion.unitedYawingAngle),"
        text += "\(motion.yawingSide),"
        text += "\(motion.percentageOfTurnsByAngle),"
        text += "\(motion.numberOfTurns),"
        text += "\n"
        print(text)
        file.write(text.data(using: .utf8)!)
        sample += 1
    }
    
    func close() {
        guard let file = self.file else { return }
        file.closeFile()
        print("\(sample) sample")
        self.file = nil
    }

    static func getDocumentPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func makeFilePath(fileAlias: String) -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = formatter.string(from: Date()) + "\(fileAlias).csv"
        let fileUrl = url.appendingPathComponent(filename)
        print(fileUrl.absoluteURL)
        return fileUrl
    }
}
class WatchMotionWriter {

    var file: FileHandle?
    var filePath: URL?
    var sample: Int = 0
    let startAt : Date = Date.now

    func open(_ filePath: URL) {
        do {
            FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            let file = try FileHandle(forWritingTo: filePath)
            var header = ""
            header += "date_now,"
            header += "acceleration_x,"
            header += "acceleration_y,"
            header += "acceleration_z,"
            header += "attitude_pitch,"
            header += "attitude_roll,"
            header += "attitude_yaw,"
//            header += "gravity_x,"
//            header += "gravity_y,"
//            header += "gravity_z,"
//            header += "quaternion_x,"
//            header += "quaternion_y,"
//            header += "quaternion_z,"
//            header += "quaternion_w,"
//            header += "rotation_x,"
//            header += "rotation_y,"
//            header += "rotation_z,"
            header += "time interval"
            header += "\n"
            file.write(header.data(using: .utf8)!)
            self.file = file
            self.filePath = filePath
        } catch let error {
            print(error)
        }
    }

    func write(_ motion: WatchMotion) {
        guard let file = self.file else { return }
        var text = ""
        let format = DateFormatter()
            format.dateFormat = "HH:mm:ss.SSS"
        format.timeZone = .current
        text += "\(format.string(from: Date(timeIntervalSince1970: motion.timestamp))),"
        text += "\(motion.userAcceleration.x),"
        text += "\(motion.userAcceleration.y),"
        text += "\(motion.userAcceleration.z),"
        text += "\(motion.attitude.pitch),"
        text += "\(motion.attitude.roll),"
        text += "\(motion.attitude.yaw),"
//        text += "\(motion.gravity.x),"
//        text += "\(motion.gravity.y),"
//        text += "\(motion.gravity.z),"
//        text += "\(motion.attitude.quaternion.x),"
//        text += "\(motion.attitude.quaternion.y),"
//        text += "\(motion.attitude.quaternion.z),"
//        text += "\(motion.attitude.quaternion.w),"
//        text += "\(motion.rotationRate.x),"
//        text += "\(motion.rotationRate.y),"
//        text += "\(motion.rotationRate.z),"
        text += "\(motion.timestamp)"
        print(text)
        text += "\n"
        file.write(text.data(using: .utf8)!)
        sample += 1
    }

    func close() {
        guard let file = self.file else { return }
        file.closeFile()
        print("\(sample) sample")
        self.file = nil
    }

    static func getDocumentPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func makeFilePath(fileAlias: String) -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = formatter.string(from: Date()) + "\(fileAlias).csv"
        let fileUrl = url.appendingPathComponent(filename)
        print(fileUrl.absoluteURL)
        return fileUrl
    }
}

struct WatchMotion{
    let timestamp : TimeInterval
    let userAcceleration: CMAcceleration
    let rotationRate : CMRotationRate
    let attitude: Attitude
    struct Attitude{
        let roll : Double
        let yaw: Double
        let pitch: Double
    }
}
import Foundation
import Spatial
struct Carv2RawData{
    let attitude: Rotation3D
    let acceleration: SIMD3<Float>
    let angularVelocity : SIMD3<Float>
    
}
