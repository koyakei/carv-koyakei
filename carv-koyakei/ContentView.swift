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
        
    }
   
}

#Preview {
    ContentView()
}



