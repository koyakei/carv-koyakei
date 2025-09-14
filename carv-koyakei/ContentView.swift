import SwiftUI

struct ContentView: View {
    @StateObject var carv2DataPair: Carv2DataPair = Carv2DataPair.shared
    var ble :BluethoothCentralManager
    @EnvironmentObject var yawingBeep: YawingBeep
    @StateObject var cameraViewModel = CameraViewModel()
    
    var body: some View {
        TabView {
            HomeView(ble: ble, carv2DataPair: carv2DataPair, yawingBeep: yawingBeep)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }.environmentObject(yawingBeep)
//            ARBootsView()
//                .tabItem {
//                    Image(systemName: "person.fill")
//                    Text("AR")
//                }
//            FootPressureView()
//                .tabItem {
//                    Image(systemName: "person.fill")
//                    Text("pressure")
//                }
            switch cameraViewModel.status {
                    case .configured:
                        YawingAnglerVelocityChartOverlay(cameraViewModel: cameraViewModel).tabItem {
                            Image(systemName: "person.fill")
                            Text("anguler")
                        }
                    case .unauthorized:
                        Text("カメラへのアクセスが許可されていません")
                    case .unconfigured:
                        ProgressView()
                    }
            
        }
    }
}



