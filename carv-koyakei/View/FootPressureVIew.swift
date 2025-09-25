//
//  FootPressureVIew.swift
//  carv-koyakei
//
//  Created by keisuke koyanagi on 2025/02/27.
//

import SwiftUI
import AudioKit
struct FootPressureView: View {
    @StateObject var carv1DataManager: Carv1DataManager
    let points: [(x: CGFloat, y: CGFloat)] = [
        (0.4, 0.1),(0.5, 0.1),
        (0.35, 0.15),(0.5, 0.15),(0.6, 0.15),
        (0.35, 0.2),(0.5, 0.2), (0.6, 0.2),
        (0.55, 0.25),
        (0.35, 0.3), (0.45, 0.3),(0.55, 0.3),(0.65, 0.3),
        (0.35, 0.35), (0.45, 0.35), (0.55, 0.35), (0.65, 0.35),
        (0.65, 0.4), (0.65, 0.45), (0.65, 0.5),
        (0.3, 0.6), (0.5, 0.6), (0.65, 0.6),
        (0.3, 0.7), (0.5, 0.7), (0.65, 0.7),
        (0.3, 0.75), (0.5, 0.75), (0.65, 0.75),
        (0.35, 0.8), (0.55, 0.8),
        (0.5, 0.9), (0.6, 0.9), (0.7, 0.9),
        (0.5, 1), (0.6, 1), (0.7, 1)
    ]
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    carv1DataManager.calibratePressureLeft()
                }){
                    Text("Left Calibrate")
                }
                
                Button(action: { carv1DataManager.calibratePressureLeft()
                }){
                    Text("Right Calibrate")
                }
            }
            HStack{
//                GeometryReader { geometry in
//                    ZStack {
//                        
//                        Color.blue // 背景色
//                        ForEach(0..<carv1DataManager.carvDataPair.left.pressure.count, id: \.self) { index in
//                            let point = points[index]
//                            let size = min(geometry.size.width, geometry.size.height)
//                            let x = point.x * size
//                            let y = point.y * size
//                            Text(carv1DataManager.carvDataPair.left.pressure[index].description)
////                            Circle()
////                                .fill(Color(white: (Double(carv1DataManager.carvDataPair.left.pressure[index]) / 60.0) ))
////                                .frame(width: size * 0.03, height: size * 0.03)
////                                .position(x: x, y: y)
//                        }
//                    }
//                }
//                .edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    ZStack {
                        Color.blue // 背景色
                        ForEach(0..<carv1DataManager.carvDataPair.right.pressure.count, id: \.self) { index in
                            let point = points[index]
                            let size = min(geometry.size.width, geometry.size.height)
                            let x = point.x * size
                            let y = point.y * size
                            Text(carv1DataManager.carvDataPair.right.pressure[index].description).position(x: x, y: y)
//                            Circle()
//                                .fill(
//                                    Color(white: (Double(carv1DataManager.carvDataPair.right.pressure[index]) / 60.0) )
//                                )
//                                .frame(width: size * 0.03, height: size * 0.03)
//                                .position(x: x, y: y)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
