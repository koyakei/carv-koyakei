import SwiftUI

struct ContentView: View {
    var ble :BluethoothCentralManager
    var yawingBeep: YawingBeep
    var rollingBeep: RollingBeep
    var cameraViewModel = CameraViewModel()
    var dataManager: DataManager
    var carv1DataManager: Carv1DataManager
    var body: some View {
        TabView {
            HomeView(ble: ble, yawingBeep: yawingBeep,rollingBeep: rollingBeep,dataManager: dataManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
//            ARBootsView()
//                .tabItem {
//                    Image(systemName: "person.fill")
//                    Text("AR")
//                }
            FootPressureView(carv1DataManager: carv1DataManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("pressure")
                }
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



