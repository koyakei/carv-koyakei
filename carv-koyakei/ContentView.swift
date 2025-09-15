import SwiftUI
import Combine

struct ContentView: View {
    var dataStore: Carv2DataPairStore
    var ble :BluethoothCentralManager
    @State var yawingBeep: YawingBeep
    var cameraViewModel = CameraViewModel()
    @State private var cancellables = Set<AnyCancellable>()
    init(_ dataStore: Carv2DataPairStore, ble: BluethoothCentralManager) {
        self.ble = ble
        self.dataStore = dataStore
        yawingBeep = YawingBeep(yawingAngulerRateDiffrential: dataStore.carv2DataPair.yawingAngulerRateDiffrential)
    }
    var body: some View {
        TabView {
            HomeView(ble: ble, dataStore: dataStore, yawingBeep: yawingBeep)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
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

