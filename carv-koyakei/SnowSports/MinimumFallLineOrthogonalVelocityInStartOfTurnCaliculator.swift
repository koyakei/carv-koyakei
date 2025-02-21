//
//  ターン前半の直交方向の最低速度.swift
//  skiBodyAttitudeTeacheer
//
//  Created by keisuke koyanagi on 2024/10/22.
//

struct MinimumFallLineOrthogonalVelocityInStartOfTurnCaliculator{
    var minVelocity : Double = 0
    
    mutating func handle( currentOrthogonalVelocity: Double){
        if currentOrthogonalVelocity > minVelocity {
            minVelocity = currentOrthogonalVelocity
        }
    }
}
