import SwiftUI

struct ContentView: View {
    
    
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
                }
            FootPressureView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("pressure")
            }
    }
}

#Preview {
    ContentView()
}



