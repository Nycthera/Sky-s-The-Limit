import SwiftUI
// to do
// im gonna cry
// 1. add tutorials
// 2. fix line rendering
// 3. stuff ig fix ui

struct ContentView: View {
    var body: some View {
        // This NavigationView is the engine that makes all NavigationLinks work.
        NavigationView {
            // It starts by showing the WelcomeView.
            FadeShowView()
        }
      
        .navigationBarHidden(true)
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
