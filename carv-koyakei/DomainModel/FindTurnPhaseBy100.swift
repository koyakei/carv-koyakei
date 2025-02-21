//
//  FindTurnPhaseBy100.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/21.
//

struct FindTurnPhaseBy100{
    func handle(currentRotationEullerAngleFromTurnSwitching: Float,
                oneTurnDiffrentialAngle: Float)-> Double{
        let percent = Double(abs(Double(currentRotationEullerAngleFromTurnSwitching)) / abs(Double(oneTurnDiffrentialAngle)))
        if percent > 1 {
            return 1.0
        } else if percent < 0 {
            return Double.zero
        } else {
            return percent
        }
    }
}
