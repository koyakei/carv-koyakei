import SwiftUI
import SwiftData
struct ContentView: View {
    var ble :BluethoothCentralManager
    var yawingBeep: YawingBeep
    var rollingBeep: RollingBeep
//    var cameraViewModel = CameraViewModel()
    var dataManager: DataManager
    var modelContainer : ModelContainer
    var carv1DataManager: Carv1DataManager
    var outsidePressureBeep: OutsidePressureBeep
    var carv1Ble:Carv1BluethoothCentralManager
//    var droggerBlueTooth: DroggerBluetoothModel
    let skateBoardDataManager:SkateBoardDataManager
    init(ble:BluethoothCentralManager, yawingBeep: YawingBeep, rollingBeep: RollingBeep,dataManager: DataManager,carv1DataManager: Carv1DataManager,outsidePressureBeep: OutsidePressureBeep,carv1Ble:Carv1BluethoothCentralManager,modelContainer:ModelContainer){
        self.ble = ble
        self.yawingBeep = yawingBeep
        self.rollingBeep = rollingBeep
        self.dataManager = dataManager
        self.carv1DataManager = carv1DataManager
        self.outsidePressureBeep = outsidePressureBeep
        self.carv1Ble = carv1Ble
        self.modelContainer = modelContainer
        self.skateBoardDataManager = SkateBoardDataManager(analysedData: SkateBoardAnalysedData(),modelContext: modelContainer.mainContext)
    }
    var body: some View {
        TabView {
            SkateBoardView(skateboard: skateBoardDataManager,modelContext: modelContainer.mainContext
            )
                .tabItem {
                    Image(systemName: "skateboard.fill")
                    Text("skateboard")
                }
            HomeView(ble: ble, yawingBeep: yawingBeep,rollingBeep: rollingBeep,dataManager: dataManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            ARBootsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("AR")
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

