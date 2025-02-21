import MultipeerConnectivity
import NearbyInteraction
import WatchConnectivity


extension CMQuaternion{
    var simdQuat : simd_quatd {
        get {
            return simd_quatd(ix: self.x,
                              iy: self.y,
                              iz: self.z,
                              r: self.w)
        }
    }
}

import CoreMotion
import Spatial
class TurnCoMManager : NSObject, ObservableObject{
    
    @Published var inclineCoM: InclineCoM?
    var startedTime: TimeInterval = Date.now.timeIntervalSince1970
    func receive(coreMotion: CMDeviceMotion, startedTime: TimeInterval,fallLineDirectionGravityAbsoluteByNorth : Rotation3D,
                 centerOfMassRelativeDirectionFromSki: Point3D
    ){
        
        inclineCoM = InclineCoM.init(
            fallLineDirectionZVerticalXTrueNorth: fallLineDirectionGravityAbsoluteByNorth, skiDirectionAbsoluteByNorth: Rotation3D.init(coreMotion.attitude.quaternion.simdQuat)
//            * Rotation3D.init(eulerAngles: EulerAngles(x: Angle2D.zero, y: Angle2D.init(degrees: 180), z: Angle2D.zero, order: EulerAngles.Order.xyz))
            , centerOfMassRelativeDirectionFromSki: centerOfMassRelativeDirectionFromSki)
    }
}



