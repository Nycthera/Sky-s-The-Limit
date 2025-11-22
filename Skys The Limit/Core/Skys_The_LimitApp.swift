import SwiftUI

@main
struct Skys_The_LimitApp: App {
    // Create a single instance of your EquationStore here.
    @StateObject private var equationStore = EquationStore()

    var body: some Scene {
        WindowGroup {
            // The ContentView is the start of your app.
            // We inject the equationStore into the environment here,
            // so all other views can access it.
            ContentView()
                .environmentObject(equationStore)
        }
    }
}
