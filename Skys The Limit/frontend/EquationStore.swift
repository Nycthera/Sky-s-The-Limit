import SwiftUI
internal import Combine

@MainActor
class EquationStore: ObservableObject {
    @Published var equations: [String] = []

    // This explicit initializer is now accessible to the rest of the app.
    init() { }
    
    func fetchEquations() {
        Task {
            print("Fetching equations from database...")
            await list_document_for_user()
            // Here you would parse the results from your database and update the array
        }
    }
    
    func saveEquation(latex: String) {
        if !equations.contains(latex) {
            equations.append(latex)
        }
        
        Task {
            print("Saving equations to database...")
            // Pass the current list of equations directly to the function
            await update_document_for_user(equations: self.equations)
        }
    }
}
