import SwiftUI

struct ContentView: View {
    @EnvironmentObject var carv2DataPair: Carv2DataPair
    @EnvironmentObject var ble :BluethoothCentralManager
    @EnvironmentObject var yawingBeep: YawingBeep
    @StateObject var cameraViewModel = CameraViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }.environmentObject(ble).environmentObject(yawingBeep)
            ARBootsView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("AR")
                }
            FootPressureView()
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

#Preview {
    ContentView().environmentObject(BluethoothCentralManager())
}



