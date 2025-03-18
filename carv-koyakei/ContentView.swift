import SwiftUI

struct ContentView: View {
    @EnvironmentObject var carv2DataPair: Carv2DataPair
    @EnvironmentObject var ble :BluethoothCentralManager
    @EnvironmentObject var yawingBeep: YawingBeep
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
        }
    }
}

#Preview {
    ContentView().environmentObject(BluethoothCentralManager())
}



