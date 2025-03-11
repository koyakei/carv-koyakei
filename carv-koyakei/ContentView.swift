import SwiftUI

struct ContentView: View {
    @EnvironmentObject var carv2DataPair: Carv2DataPair
    var body: some View {
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
            FootPressureView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("pressure")
                }
        }
    }
}

#Preview {
    ContentView()
}



