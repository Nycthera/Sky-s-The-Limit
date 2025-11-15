import Foundation

// This struct represents a single, identifiable line in our drawing.
struct EquationLine: Identifiable {
    let id = UUID()
    var latexString: String
    
   
    // This property is NOT optional. It matches the return type of your
    // original MathEngine's calculatePoints() function.
    var points: [(x: Double, y: Double)] = []
}
