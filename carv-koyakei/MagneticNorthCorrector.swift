import CoreLocation
import simd

class MagneticNorthCorrector {
    private let locationManager = CLLocationManager()
    
    func apply(sensorRotation: simd_quatf, deviceTransform: float4x4) -> simd_quatf {
        guard let heading = locationManager.heading else { return sensorRotation }
        
        // デバイスの姿勢を考慮した磁北補正
        let deviceRotation = simd_quatf(deviceTransform)
        let northRotation = simd_quatf(angle: Float(-heading.magneticHeading).degreesToRadians,
                                      axis: [0, 1, 0])
        
        return sensorRotation * northRotation * deviceRotation.inverse
    }
}
