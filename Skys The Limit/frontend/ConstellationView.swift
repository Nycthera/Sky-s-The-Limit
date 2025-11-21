import SwiftUI
import SwiftMath

struct ConstellationView: View {
    @EnvironmentObject var equationStore: EquationStore
    
    @State private var showModal = false
    @State private var constellationName = ""
    @State private var numberOfStars: Int? = nil
    @State private var isShared = false
    
    // Track selected constellation to show in canvas
    @State private var selectedConstellation: Constellation? = nil
     
    // Store constellation rows from Appwrite
    @State private var constellations: [Constellation] = []
    
    let deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    
    // 2-column flexible grid
    private static let gridColumns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            Image("Space")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: Self.gridColumns, spacing: 20) {
                    ForEach(constellations) { constellation in
                        ConstellationCellView(constellation: constellation)
                            .onTapGesture {
                                selectedConstellation = constellation
                            }
                    }
                }
                .padding()
            }
      
        }
        // <-- Full screen cover to show the selected constellation
        .fullScreenCover(item: $selectedConstellation) { constellation in
            CustomConstellationView(ID: constellation.id)
            
        }
        .onAppear {
            Task {
                await loadConstellations()
            }
        }
    }
    
    // MARK: - Load all documents from Appwrite
    func loadConstellations() async {
        await list_document_for_user()
        
        var fetched: [Constellation] = []
        
        for id in userTableIDs {
            if let doc = await get_document_for_user(rowId: id) {
                fetched.append(doc)
            }
        }
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.constellations = fetched
        }
    }
    // Sample points from an equation using MathEngine
    private func samplePoints(for equation: String, xRange: ClosedRange<Double> = -10...10, step: Double = 0.5) -> [(x: Double, y: Double)] {
        let engine = MathEngine(equation: equation)
        return engine.calculatePoints(xRange: xRange, step: step) // returns [(x,y)]
    }

    // Find approximate x where two sampled curves are closest (coarse search)
    private func findApproxIntersectionX(eq1: String, eq2: String, xRange: ClosedRange<Double> = -10...10, step: Double = 0.5) -> Double? {
        let pts1 = samplePoints(for: eq1, xRange: xRange, step: step).sorted { $0.x < $1.x }
        let pts2 = samplePoints(for: eq2, xRange: xRange, step: step).sorted { $0.x < $1.x }
        guard !pts1.isEmpty && !pts2.isEmpty else { return nil }

        // For each sampled x in pts1, find closest y in pts2 (by x proximity interpolation)
        var bestX: Double? = nil
        var bestDist = Double.greatestFiniteMagnitude

        for p1 in pts1 {
            // find p2 with closest x (could be improved with interpolation)
            if let p2 = pts2.min(by: { abs($0.x - p1.x) < abs($1.x - p1.x) }) {
                let d = abs(p1.y - p2.y)
                if d < bestDist {
                    bestDist = d
                    bestX = (p1.x + p2.x) / 2.0
                }
            }
        }

        // If bestDist is reasonable, return the x
        return bestX
    }

    // Refine intersection x with a simple bisection-like search on difference f(x) = y1(x)-y2(x)
    private func refineIntersection(eq1: String, eq2: String, initialX: Double, radius: Double = 1.0, steps: Int = 40) -> (x: Double, y: Double)? {
        // Make local closure to evaluate y for an equation at x using MathEngine
        func yAt(_ equation: String, _ x: Double) -> Double? {
            let processed = MathEngine(equation: equation)
            // Use calculatePoints with small step centered near x to try to evaluate
            // Simpler: replace "x" by (x) and evaluate single point via calculatePoints but it samples many x
            let replaced = equation.replacingOccurrences(of: "x", with: "(\(x))")
            let engine = MathEngine(equation: replaced)
            let pts = engine.calculatePoints(xRange: x...x, step: 1.0)
            if let p = pts.first {
                return p.y
            }
            return nil
        }

        var left = initialX - radius
        var right = initialX + radius
        var bestX = initialX
        var bestValue = Double.greatestFiniteMagnitude

        for _ in 0..<steps {
            let mid = (left + right) / 2.0
            guard let y1 = yAt(eq1, mid), let y2 = yAt(eq2, mid) else { break }
            let diff = y1 - y2
            if abs(diff) < abs(bestValue) {
                bestValue = diff
                bestX = mid
            }
            // decide which side likely reduces difference by sampling
            // sample left-mid and mid-right
            let leftMid = (left + mid) / 2.0
            let rightMid = (mid + right) / 2.0
            let leftDiff = (yAt(eq1, leftMid) ?? Double.greatestFiniteMagnitude) - (yAt(eq2, leftMid) ?? 0)
            let rightDiff = (yAt(eq1, rightMid) ?? Double.greatestFiniteMagnitude) - (yAt(eq2, rightMid) ?? 0)

            // choose narrower interval where |diff| is smaller
            if abs(leftDiff) < abs(rightDiff) {
                right = mid
            } else {
                left = mid
            }
        }

        if let y1 = yAt(eq1, bestX), let y2 = yAt(eq2, bestX) {
            return (x: bestX, y: (y1 + y2) / 2.0)
        }
        return nil
    }

}

// Helper extension for chunking arrays into consecutive pairs
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var chunks: [[Element]] = []
        var index = 0
        while index < count {
            let end = Swift.min(index + size, count)
            chunks.append(Array(self[index..<end]))
            index += size
        }
        return chunks
    }
}

private struct ConstellationCellView: View {
    let constellation: Constellation
    // Passed from parent
    let stars: [CGPoint]
    let successfulLines: [[(x: Double, y: Double)]]
    let equations: [String]
    let ID: String
    let name: String?   // <-- new optional property
    
    var body: some View {
        VStack(spacing: 12) {
            Text(name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("\((constellation.equations ?? []).count) equations")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            if (constellation.isShared ?? false) {
                Text("Shared")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ConstellationView()
        .environmentObject(EquationStore())
}
