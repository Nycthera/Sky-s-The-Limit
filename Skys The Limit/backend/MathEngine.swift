//
//  MathEngine.swift
//  Skys The Limit
//
//  Created by Chris on 7/11/25.
//

import Foundation

enum EquationType: String {
    case linear = "Linear"
    case quadratic = "Quadratic"
    case trigonometric = "Trigonometric"
    case exponential = "Exponential"
    case logarithmic = "Logarithmic"
    case constant = "Constant"
    case unknown = "Unknown"
}

class MathEngine {
    var equation: String
    // Default values for symbolic coefficients
    var coefficients: [String: Double] = ["a": 1, "b": 1, "c": 1, "m": 1, "n": 1]

    init(equation: String) {
        // Remove spaces for easier processing
        self.equation = equation.replacingOccurrences(of: " ", with: "")
    }

    // MARK: - Detect Equation Type
    func detectType() -> EquationType {
        let eq = equation.lowercased().replacingOccurrences(of: #"^[a-z]\s*="#, with: "", options: .regularExpression)
        
        if eq.range(of: #"sin|cos|tan"#, options: .regularExpression) != nil {
            return .trigonometric
        } else if eq.range(of: #"e\^|exp"#, options: .regularExpression) != nil {
            return .exponential
        } else if eq.range(of: #"log|ln"#, options: .regularExpression) != nil {
            return .logarithmic
        } else if eq.range(of: #"[xy]\^2"#, options: .regularExpression) != nil {
            return .quadratic
        } else if eq.range(of: #"[xy]"#, options: .regularExpression) != nil {
            return .linear
        } else if eq.range(of: #"^[0-9\.\-]+$"#, options: .regularExpression) != nil {
            return .constant
        } else {
            return .unknown
        }
    }

    // MARK: - Validate Equation
    func isValid() -> Bool {
        // Allow letters, numbers, math symbols, and "="
        let validPattern = #"^[0-9a-zA-Z\^\+\-\*\/\(\)\s\.\=]+$"#
        return equation.range(of: validPattern, options: .regularExpression) != nil
    }

    // MARK: - Prepare equation for evaluation
    private func preprocessEquation() -> String {
        var eq = equation.replacingOccurrences(of: "y=", with: "", options: .caseInsensitive)
        
        // Replace symbolic coefficients with numeric defaults
        for (symbol, value) in coefficients {
            eq = eq.replacingOccurrences(of: symbol, with: "(\(value))")
        }

        // Convert powers: x^2 → pow(x,2)
        let powerPattern = #"([0-9\(\)\+\-\*/]+)\^([0-9\(\)\+\*/]+)"#
        let regex = try! NSRegularExpression(pattern: powerPattern)
        while let match = regex.firstMatch(in: eq, range: NSRange(eq.startIndex..., in: eq)) {
            guard let baseRange = Range(match.range(at: 1), in: eq),
                  let expRange = Range(match.range(at: 2), in: eq) else { break }
            let base = eq[baseRange]
            let exp = eq[expRange]
            let replacement = "pow(\(base),\(exp))"
            eq.replaceSubrange(baseRange.lowerBound..<expRange.upperBound, with: replacement)
        }

        // Add explicit multiplication: 2x → 2*x, 3(x+1) → 3*(x+1)
        eq = eq.replacingOccurrences(of: #"([0-9\)])x"#,
                                     with: "$1*x",
                                     options: .regularExpression)
        eq = eq.replacingOccurrences(of: #"x\("#,
                                     with: "x*(",
                                     options: .regularExpression)

        return eq
    }

    // MARK: - Calculate points
    func calculatePoints(xRange: ClosedRange<Double> = -10...10, step: Double = 1.0) -> [(x: Double, y: Double)] {
        var points: [(x: Double, y: Double)] = []
        let cleanEquation = preprocessEquation()

        for x in stride(from: xRange.lowerBound, through: xRange.upperBound, by: step) {
            let exprString = cleanEquation.replacingOccurrences(of: "x", with: "(\(x))")
            let expression = NSExpression(format: exprString)
            
            if let y = expression.expressionValue(with: nil, context: nil) as? Double,
               y.isFinite { // skip NaN or Inf
                points.append((x, y))
            }
        }

        return points
    }

    // MARK: - Evaluate
    func evaluate() -> [(x: Double, y: Double)]? {
        guard isValid() else {
            print("Invalid equation format!")
            return nil
        }
        let type = detectType()
        print("Equation Type Detected: \(type.rawValue)")
        return calculatePoints()
    }
}
