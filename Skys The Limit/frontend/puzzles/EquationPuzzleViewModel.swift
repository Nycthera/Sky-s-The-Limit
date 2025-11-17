// What this file does: It stores the game state (stars, lines, equations).
//It checks if the user entered the correct equation.
//It updates the line preview while the user types.
//It decides when the puzzle is solved.
                
import Foundation
import CoreGraphics
import Combine

@MainActor
class EquationPuzzleViewModel: ObservableObject {
    // The puzzle state
    @Published var stars: [CGPoint] = []
    @Published var successfulLines: [[(x: Double, y: Double)]] = []
    @Published var successfulEquations: [String] = []
    
    // The current user input state
    @Published var currentLatexString: String = "y="
    @Published var currentGraphPoints: [(x: Double, y: Double)] = []
    
    // The game flow state
    @Published var currentTargetIndex: Int = 0
    @Published var isPuzzleComplete: Bool = false

    init() {
        generateNewPuzzle()
    }
    
    /// Generates a new set of random stars and resets the game state.
    func generateNewPuzzle(starCount: Int = 4) {
        stars.removeAll()
        successfulLines.removeAll()
        currentTargetIndex = 0
        isPuzzleComplete = false
        resetCurrentLine()
        
        var usedPoints = Set<CGPoint>()
        for _ in 0..<starCount {
            var newPoint: CGPoint
            repeat {
                newPoint = CGPoint(x: Int.random(in: -8...8), y: Int.random(in: -8...8))
            } while usedPoints.contains(newPoint)
            stars.append(newPoint)
            usedPoints.insert(newPoint)
        }
    }
    
    /// Updates the live preview of the user's current equation.
    func updateUserGraph() {
        let engine = MathEngine(equation: currentLatexString)
        // Use evaluate() to validate and compute points (with logging/type detection),
        // or calculatePoints(...) directly if you want silent computation.
        if let points = engine.evaluate() {
            currentGraphPoints = points
        } else {
            currentGraphPoints = []
        }
    }
    
    // Checks if the user's current line correctly connects the two target stars.
    func checkCurrentLineSolution() {
        guard stars.count > currentTargetIndex + 1 else { return }
        
        let starA = stars[currentTargetIndex]
        let starB = stars[currentTargetIndex + 1]
        let tolerance = 0.5
        
        let connectsStarA = lineContainsPoint(line: currentGraphPoints, point: starA, tolerance: tolerance)
        let connectsStarB = lineContainsPoint(line: currentGraphPoints, point: starB, tolerance: tolerance)
        
        if connectsStarA && connectsStarB {
            successfulLines.append(currentGraphPoints)
            successfulEquations.append(currentLatexString)
            currentTargetIndex += 1
            
            if currentTargetIndex >= stars.count - 1 {
                isPuzzleComplete = true
            }
            resetCurrentLine()
        }
    }
    
    private func resetCurrentLine() {
        currentLatexString = "y="
        currentGraphPoints.removeAll()
    }
    
    private func lineContainsPoint(line: [(x: Double, y: Double)], point: CGPoint, tolerance: Double) -> Bool {
        return line.contains { linePoint in
            let dx = linePoint.x - point.x
            let dy = linePoint.y - point.y
            return sqrt(dx*dx + dy*dy) < tolerance
        }
    }
    
    func generateLinePoints() {
        let engine = MathEngine(equation: currentLatexString)
        // Choose either evaluate() or calculatePoints with desired sampling.
        if let points = engine.evaluate() {
            currentGraphPoints = points
        } else {
            currentGraphPoints = []
        }
    }
}

