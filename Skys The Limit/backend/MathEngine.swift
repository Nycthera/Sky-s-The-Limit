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

final class MathEngine {
    
    // Raw equation string from user
    var equation: String
    var domainRule: String?
    
    // Default numeric values for symbolic coefficients
    var coefficients: [String: Double] = [
        "a": 1, "b": 1, "c": 1,
        "m": 1, "n": 1
    ]
    
    private let disallowedExpressionCharacters = CharacterSet(charactersIn: "\"|")
    
    // ------------------------------------------------------------
    // MARK: - Init
    // ------------------------------------------------------------
    init(equation: String) {
        self.equation = equation.replacingOccurrences(of: " ", with: "")
        
        // Extract domain rule e.g. {...}
        if let start = self.equation.firstIndex(of: "{"),
           let end = self.equation.firstIndex(of: "}") {
            let rule = self.equation[self.equation.index(after: start)..<end]
            self.domainRule = String(rule)
            self.equation.removeSubrange(start...end)
        }
    }
    
    // ------------------------------------------------------------
    // MARK: - Detect Equation Type
    // ------------------------------------------------------------
    func detectType() -> EquationType {
        let eq = strippedEquation()
        
        if eq.range(of: #"sin|cos|tan"#, options: .regularExpression) != nil {
            return .trigonometric
        }
        if eq.range(of: #"e\^|exp"#, options: .regularExpression) != nil {
            return .exponential
        }
        if eq.range(of: #"log|ln"#, options: .regularExpression) != nil {
            return .logarithmic
        }
        if eq.range(of: #"[xy]\^2"#, options: .regularExpression) != nil {
            return .quadratic
        }
        if eq.range(of: #"[xy]"#, options: .regularExpression) != nil {
            return .linear
        }
        if eq.range(of: #"^[0-9\.\-]+$"#, options: .regularExpression) != nil {
            return .constant
        }
        return .unknown
    }
    
    // ------------------------------------------------------------
    // MARK: - Strip LHS and cleanup
    // ------------------------------------------------------------
    private func strippedEquation() -> String {
        // Remove leading 'y=' or 'f(x)=' or any letter followed by '='
        let eq = equation.replacingOccurrences(
            of: #"^[a-zA-Z]+\s*="#,
            with: "",
            options: .regularExpression
        )
        return eq
    }
    
    // ------------------------------------------------------------
    // MARK: - Validate Format
    // ------------------------------------------------------------
    func isValid() -> Bool {
        let eq = strippedEquation()
        let validPattern = #"^[0-9a-zA-Z\^\+\-\*\/\(\)\.]+$"#
        return eq.range(of: validPattern, options: .regularExpression) != nil
    }
    
    // ------------------------------------------------------------
    // MARK: - Safe Expression Check
    // ------------------------------------------------------------
    private func makeSafeExpressionString(_ input: String) -> String? {
        var cleaned = input
        
        // 1. Remove '=' just in case
        cleaned = cleaned.replacingOccurrences(of: "=", with: "")
        
        // 2. Reject comparison operators
        let comparisons = ["==", "!=", "<=", ">=", "<", ">"]
        for op in comparisons {
            if cleaned.contains(op) { return nil }
        }
        
        // 3. Reject unsafe characters
        if cleaned.rangeOfCharacter(from: disallowedExpressionCharacters) != nil {
            return nil
        }
        
        // 4. Only allow math-safe characters
        let validPattern = #"^[0-9a-zA-Z\^\+\-\*\/\(\)\.]+$"#
        guard cleaned.range(of: validPattern, options: .regularExpression) != nil else {
            return nil
        }
        
        return cleaned
    }
    
    // ------------------------------------------------------------
    // MARK: - Preprocess Equation
    // ------------------------------------------------------------
    private func preprocessEquation() -> String {
        var eq = strippedEquation()
        
        // Replace coefficients a,b,c etc
        for (symbol, value) in coefficients {
            let pattern = "(?<![a-zA-Z])\(symbol)(?![a-zA-Z])"
            eq = eq.replacingOccurrences(of: pattern,
                                         with: "(\(value))",
                                         options: .regularExpression)
        }
        
        // Convert ^ → pow()
        let powerPattern = #"([a-zA-Z0-9\)\(]+)\^([a-zA-Z0-9\)\(]+)"#
        let regex = try! NSRegularExpression(pattern: powerPattern)
        while let match = regex.firstMatch(in: eq, range: NSRange(eq.startIndex..., in: eq)) {
            let base = Range(match.range(at: 1), in: eq)!
            let exp  = Range(match.range(at: 2), in: eq)!
            let replacement = "pow(\(eq[base]),\(eq[exp]))"
            eq.replaceSubrange(base.lowerBound..<exp.upperBound, with: replacement)
        }
        
        // 2x -> 2*x, x( -> x*(
        eq = eq.replacingOccurrences(of: #"([0-9\)])x"#, with: "$1*x", options: .regularExpression)
        eq = eq.replacingOccurrences(of: #"x\("#, with: "x*(", options: .regularExpression)
        
        return eq
    }
    
    // ------------------------------------------------------------
    // MARK: - Domain Check
    // ------------------------------------------------------------
    private func xSatisfiesDomain(_ x: Double) -> Bool {
        guard let rule = domainRule else { return true }
        let pattern = #"(-?[0-9\.]+)\s*([<>]=?)\s*x\s*([<>]=?)\s*(-?[0-9\.]+)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: rule, range: NSRange(rule.startIndex..., in: rule)) {
            
            let leftValue = Double((rule as NSString).substring(with: match.range(at: 1)))!
            let leftOp = (rule as NSString).substring(with: match.range(at: 2))
            let rightOp = (rule as NSString).substring(with: match.range(at: 3))
            let rightValue = Double((rule as NSString).substring(with: match.range(at: 4)))!
            
            let leftOK: Bool = {
                switch leftOp {
                case "<": return leftValue < x
                case "<=": return leftValue <= x
                case ">": return leftValue > x
                case ">=": return leftValue >= x
                default: return false
                }
            }()
            
            let rightOK: Bool = {
                switch rightOp {
                case "<": return x < rightValue
                case "<=": return x <= rightValue
                case ">": return x > rightValue
                case ">=": return x >= rightValue
                default: return false
                }
            }()
            
            return leftOK && rightOK
        }
        return true
    }
    
    // ------------------------------------------------------------
    // MARK: - Calculate points
    // ------------------------------------------------------------
    func calculatePoints(
        xRange: ClosedRange<Double> = -10...10,
        step: Double = 1.0
    ) -> [(x: Double, y: Double)] {
        
        var result: [(x: Double, y: Double)] = []
        let processed = preprocessEquation()
        
        for x in stride(from: xRange.lowerBound, through: xRange.upperBound, by: step) {
            if !xSatisfiesDomain(x) { continue }
            
            // Substitute x
            let substituted = processed.replacingOccurrences(of: "x", with: "(\(x))")
            
            guard let safeExpr = makeSafeExpressionString(substituted) else {
                print("Skipping unsafe expression:", substituted)
                continue
            }
            
            let expr = NSExpression(format: safeExpr)
            if let y = expr.expressionValue(with: nil, context: nil) as? Double,
               y.isFinite {
                result.append((x, y))
            }
        }
        
        return result
    }
    
    // ------------------------------------------------------------
    // MARK: - Public Evaluate
    // ------------------------------------------------------------
    func evaluate() -> [(x: Double, y: Double)]? {
        guard isValid() else {
            print("Invalid equation format!")
            return nil
        }
        
        let type = detectType()
        print("Equation Type:", type.rawValue)
        
        let points = calculatePoints()
        
        let pretty = points.map { "(\($0.x), \($0.y))" }.joined(separator: ", ")
        print("[\(pretty)]")
        
        return points
    }
}
