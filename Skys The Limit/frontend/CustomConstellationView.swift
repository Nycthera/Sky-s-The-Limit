//
//  CustomConstellationView.swift
//  Skys The Limit
//
//  Created by Chris on 19/11/25.
//

import SwiftUI
import SwiftMath

struct CustomConstellationView: View {
    @State private var arrayOfEquations: [String] = []
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []

    // Separate strings for display and math engine
    @State private var editingLatexString: String = ""
    @State private var editingMathString: String = ""
    @State private var editingIndex: Int? = nil // nil = new, else edit mode
    @State private var isSidebarCollapsed = false
    @State private var showSaveModal = false // Save modal

    @Environment(\.presentationMode) var presentationMode
    let ID: String
    private let sidebarWidth: CGFloat = 250

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    // Background
                    Image("Space")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    HStack(spacing: 0) {
                        // Sidebar
                        CustomSidebarView(
                            isCollapsed: isSidebarCollapsed,
                            equations: $arrayOfEquations,
                            editingString: $editingLatexString,
                            editingIndex: $editingIndex
                        )

                        // Game Area
                        VStack(spacing: 15) {
                            // Canvas
                            CustomGraphCanvasView(
                                stars: stars,
                                successfulLines: successfulLines,
                                equations: arrayOfEquations,
                                ID: ID,
                                name: "Orion"   // <-- or dynamically fetch from your database
                            )
                            .frame(height: geo.size.height * 0.4)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .layoutPriority(1)

                            // Keyboard
                            MathKeyboardView(
                                latexString: $editingLatexString,
                                mathString: $editingMathString
                            )
                            .layoutPriority(1)

            

                            // Current input display
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Current Input:")
                                    .font(.custom("SpaceMono-Bold", size: 16))
                                    .foregroundColor(.white)
                                Text(editingLatexString.isEmpty ? "(empty)" : editingLatexString)
                                    .font(.custom("SpaceMono-Regular", size: 16))
                                    .foregroundColor(.yellow)
                                    .padding(6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)

                            Spacer(minLength: 0)
                        }
                        .padding()
                        .frame(width: geo.size.width - (isSidebarCollapsed ? 0 : sidebarWidth))
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut) { isSidebarCollapsed.toggle() }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 25))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Save icon
                        Button {
                            showSaveModal = true
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        // Back button
                        Button("Back") { presentationMode.wrappedValue.dismiss() }
                            .font(.custom("SpaceMono-Regular", size: 18))
                            .padding(5)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            // Save modal
            .sheet(isPresented: $showSaveModal) {
                SaveConstellationModalView(
                    isPresented: $showSaveModal,
                    equations: $arrayOfEquations,
                )
            }

            .onAppear {
                Task {
                    if let constellation: Constellation = await get_document_for_user(rowId: ID) {
                        self.arrayOfEquations = constellation.equations ?? []
                    }
                }
            }
            // Auto-update canvas whenever equations change
            .onChange(of: arrayOfEquations) { _ in
                updateStarsFromEquations()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Update stars from equations
    private func updateStarsFromEquations() {
        var allPoints: [(x: Double, y: Double)] = []

        // quick heuristic to decide whether arrayOfEquations contains coordinates or equations:
        // if most entries contain a comma but no '=' assume coordinates
        let commaCount = arrayOfEquations.filter { $0.contains(",") }.count
        let equalsCount = arrayOfEquations.filter { $0.contains("=") }.count

        if commaCount >= equalsCount {
            // treat as coordinate pairs
            for eqStr in arrayOfEquations {
                let components = eqStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if components.count == 2,
                   let x = Double(components[0]),
                   let y = Double(components[1]) {
                    allPoints.append((x: x, y: y))
                } else {
                    // try JSON decode like {"x":2,"y":5}
                    if let data = eqStr.data(using: .utf8),
                       let obj = try? JSONSerialization.jsonObject(with: data, options: []),
                       let dict = obj as? [String: Any],
                       let x = (dict["x"] as? Double) ?? (dict["x"] as? Int).map(Double.init),
                       let y = (dict["y"] as? Double) ?? (dict["y"] as? Int).map(Double.init) {
                        allPoints.append((x: x, y: y))
                    }
                }
            }
            // set stars & lines
            self.stars = allPoints.map { CGPoint(x: $0.x, y: $0.y) }
            self.successfulLines = allPoints.chunked(into: 2)
            print("Loaded legacy coordinate stars:", self.stars)
            return
        }

        // Else assume equations — reconstruct intersections between consecutive equations
        let equations = arrayOfEquations.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        for i in 0..<(equations.count - 1) {
            let eqA = equations[i]
            let eqB = equations[i + 1]

            // coarse search for approximate x
            if let approxX = findApproxIntersectionX(eq1: eqA, eq2: eqB, xRange: -10...10, step: 0.5) {
                // refine
                if let refined = refineIntersection(eq1: eqA, eq2: eqB, initialX: approxX, radius: 1.0, steps: 40) {
                    allPoints.append((x: refined.x, y: refined.y))
                    continue
                }
            }

            // As fallback: sample eqA and pick first sample point (so something shows)
            if let first = samplePoints(for: eqA, xRange: -10...10, step: 1.0).first {
                allPoints.append(first)
            }
        }

        // If we reconstructed N intersections, use them as stars.
        self.stars = allPoints.map { CGPoint(x: $0.x, y: $0.y) }
        self.successfulLines = allPoints.chunked(into: 2)
        print("Reconstructed stars from equations:", self.stars)
    }

}
    
// MARK: - Sidebar
private struct CustomSidebarView: View {
    let isCollapsed: Bool
    @Binding var equations: [String]
    @Binding var editingString: String
    @Binding var editingIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isCollapsed {
                Text("Equations")
                    .font(.custom("SpaceMono-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(equations.indices, id: \.self) { idx in
                            MathView(
                                equation: equations[idx],
                                textAlignment: .left,
                                fontSize: 20
                            )
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                editingString = equations[idx]
                                editingIndex = idx
                            }
                            .onLongPressGesture {
                                withAnimation {
                                    equations.remove(at: idx)
                                    if editingIndex == idx {
                                        editingString = ""
                                        editingIndex = nil
                                    } else if let current = editingIndex, current > idx {
                                        editingIndex = current - 1
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }

                // Input for new equation / edit
                VStack(spacing: 5) {
                    Text("New Equation / Edit:")
                        .font(.custom("SpaceMono-Bold", size: 16))
                        .foregroundColor(.white)

                    TextField("Type here...", text: $editingString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 8)
                        .font(.custom("SpaceMono-Regular", size: 16))
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 8)
            }

            Spacer()
        }
        .frame(width: isCollapsed ? 0 : 250)
        .clipped()
        .background(isCollapsed ? Color.clear : Color.black.opacity(0.4))
    }
}

// MARK: - Helpers copied from ConstellationView so this file compiles

// Sample points from an equation using MathEngine
private func samplePoints(for equation: String, xRange: ClosedRange<Double> = -10...10, step: Double = 0.5) -> [(x: Double, y: Double)] {
    let engine = MathEngine(equation: equation)
    return engine.calculatePoints(xRange: xRange, step: step)
}

// Find approximate x where two sampled curves are closest (coarse search)
private func findApproxIntersectionX(eq1: String, eq2: String, xRange: ClosedRange<Double> = -10...10, step: Double = 0.5) -> Double? {
    let pts1 = samplePoints(for: eq1, xRange: xRange, step: step).sorted { $0.x < $1.x }
    let pts2 = samplePoints(for: eq2, xRange: xRange, step: step).sorted { $0.x < $1.x }
    guard !pts1.isEmpty && !pts2.isEmpty else { return nil }

    var bestX: Double? = nil
    var bestDist = Double.greatestFiniteMagnitude

    for p1 in pts1 {
        if let p2 = pts2.min(by: { abs($0.x - p1.x) < abs($1.x - p1.x) }) {
            let d = abs(p1.y - p2.y)
            if d < bestDist {
                bestDist = d
                bestX = (p1.x + p2.x) / 2.0
            }
        }
    }
    return bestX
}

// Refine intersection x with a simple search on difference f(x) = y1(x)-y2(x)
private func refineIntersection(eq1: String, eq2: String, initialX: Double, radius: Double = 1.0, steps: Int = 40) -> (x: Double, y: Double)? {
    func yAt(_ equation: String, _ x: Double) -> Double? {
        // Evaluate near a single x by substituting and sampling at that exact x
        let replaced = equation.replacingOccurrences(of: "x", with: "(\(x))")
        let engine = MathEngine(equation: replaced)
        let pts = engine.calculatePoints(xRange: x...x, step: 1.0)
        return pts.first?.y
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
        let leftMid = (left + mid) / 2.0
        let rightMid = (mid + right) / 2.0
        let leftDiff = (yAt(eq1, leftMid) ?? Double.greatestFiniteMagnitude) - (yAt(eq2, leftMid) ?? 0)
        let rightDiff = (yAt(eq1, rightMid) ?? Double.greatestFiniteMagnitude) - (yAt(eq2, rightMid) ?? 0)

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

//// Helper extension for chunking arrays into consecutive pairs
//extension Array {
//    func chunked(into size: Int) -> [[Element]] {
//        guard size > 0 else { return [] }
//        var chunks: [[Element]] = []
//        var index = 0
//        while index < count {
//            let end = Swift.min(index + size, count)
//            chunks.append(Array(self[index..<end]))
//            index += size
//        }
//        return chunks
//    }
//}
