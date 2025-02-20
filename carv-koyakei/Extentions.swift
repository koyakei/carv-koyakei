//
//  Extentions.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/04.
//
import Foundation

extension Data {
    func toFloatArray(endianness: Endianness = .big) -> [Float]? {
//        guard self.count % MemoryLayout<Float>.size == 0 else {
//            print("Invalid data size: \(self.count) bytes")
//            return nil
//        }
        
        return self.withUnsafeBytes { rawBuffer -> [Float] in
            let uint32Buffer = rawBuffer.bindMemory(to: UInt32.self)
            return uint32Buffer.map { uint32 in
                let adjusted = endianness == .little ? uint32.littleEndian : uint32.bigEndian
                return Float(bitPattern: adjusted)
            }
        }
    }
}
enum Endianness {
    case little
    case big
}

import simd
extension simd_quatd {
    var formatQuaternion: String {
        let components = [self.real, self.imag.x, self.imag.y, self.imag.z]
        
        let rounded = components.map { value in
            String(format: "%.1f", round(value * 10) / 10)  // 四捨五入処理
        }
        
        return """
        simd_quatd(
            real: \(rounded[0]),
            ix: \(rounded[1]),
            iy: \(rounded[2]),
            iz: \(rounded[3])
        )
        """
    }
}
