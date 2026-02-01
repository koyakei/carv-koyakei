import SwiftUI

struct ContentView: View {
    @ObservedObject var ble :Carv2BluethoothCentralManager
//    var cameraViewModel = CameraViewModel()
    var dataManager: CarvDataManager
    var carv1DataManager: Carv1DataManager
    var outsidePressureBeep: OutsidePressureBeep
    var carv1Ble:Carv1BluethoothCentralManager
    var skateBoardDataManager: SkateBoardDataManager
    var droggerBlueTooth: DroggerBluetoothModel
    var body: some View {
        TabView {
            HomeView(dataManager: dataManager, bleManager: ble)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            Carv1View(dataManager: carv1DataManager,ble: carv1Ble,outsidePressureBeep: outsidePressureBeep)
                .tabItem {
                    Text("carv1")
                }
            FootPressureView(carv1DataManager: carv1DataManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("pressure")
                }
            SkateBoardView(skateboard: skateBoardDataManager
//                           ,droggerBluetooth: droggerBlueTooth
            )
                .tabItem {
                    Image(systemName: "skateboard.fill")
                    Text("skateboard")
                }
            
//            ARBootsView(dataManager: dataManager)
//                .tabItem {
//                    Image(systemName: "person.fill")
//                    Text("AR")
//                }
            
            
            
//            switch cameraViewModel.status {
//                    case .configured:
//                        YawingAnglerVelocityChartOverlay(cameraViewModel: cameraViewModel).tabItem {
//                            Text("anguler")
//                        }
//                    case .unauthorized:
//                        Text("カメラへのアクセスが許可されていません")
//                    case .unconfigured:
//                        ProgressView()
//                    }
            
        }
    }
}
