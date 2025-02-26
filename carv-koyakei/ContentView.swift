import SwiftUI
import Combine
import CoreBluetooth
import Spatial
import SceneKit
import RealityKit
import Spatial
import simd
import ARKit

struct ContentView: View {
//    @StateObject private var conductor = DynamicOscillatorConductor()
//    @State private var parallelAngle2 : Double = 0
//    @State private var diffTargetAngle : Float = 1.5
    
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
        (0.5, 0.9)
    ]
    var body: some View {
        
        
        
//        HStack{
//            GeometryReader { geometry in
//                ZStack {
//                    Color.blue // 背景色
//                    
//                    ForEach(0..<points.count, id: \.self) { index in
//                        let point = points[index]
//                        let size = min(geometry.size.width, geometry.size.height)
//                        let x = point.x * size
//                        let y = point.y * size
//                        Circle()
//                            .fill(Color(white: (Double(carv1DataPair.left.pressure[index]) / 60.0) ))
//                            .frame(width: size * 0.03, height: size * 0.03)
//                            .position(x: x, y: y)
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//            GeometryReader { geometry in
//                ZStack {
//                    Color.blue // 背景色
//                    
//                    ForEach(0..<points.count, id: \.self) { index in
//                        let point = points[index]
//                        let size = min(geometry.size.width, geometry.size.height)
//                        let x = point.x * size
//                        let y = point.y * size
//                        Text(carv1DataPair.left.pressure[index].hex).position(x: x, y: y)
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//        }
            
        TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("ホーム")
                        }
                
                    
            ARBootsView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("AR")
                        }
                }
        
    }
   
}



#Preview {
    ContentView()
}



