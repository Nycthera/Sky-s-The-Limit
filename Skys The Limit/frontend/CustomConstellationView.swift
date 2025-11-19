//
//  CustomConstellationView.swift
//  Skys The Limit
//
//  Created by Chris  on 19/11/25.
//

import Foundation
import SwiftUI

struct CustomConstellationView: View {
    
    @State private var selectedStarCoordinates: String? = nil
    @State private var selectedStarIndex: Int? = nil

    let stars: [CGPoint]
    let successfulLines: [[(x: Double, y: Double)]]
    let currentLine: [(x: Double, y: Double)]
    let currentTargetIndex: Int
    let connectedStarIndices: Set<Int>
    
    private let xRange: ClosedRange<Double> = -10...10
    private let yRange: ClosedRange<Double> = -10...10
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let xScale = size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                let yScale = size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
                
                context.translateBy(x: size.width / 2, y: size.height / 2)
                
                // --- Layer 0: Grid lines ---
                drawGrid(context: context, size: size, xScale: xScale, yScale: yScale)
                
                // --- Layer 1: Axes ---
                var axes = Path()
                axes.move(to: CGPoint(x: -size.width/2, y: 0))
                axes.addLine(to: CGPoint(x: size.width/2, y: 0))
                axes.move(to: CGPoint(x: 0, y: -size.height/2))
                axes.addLine(to: CGPoint(x: 0, y: size.height/2))
                context.stroke(axes, with: .color(.white.opacity(0.7)), lineWidth: 2)
                
                // --- Layer 2: Completed lines ---
                for (lineIndex, line) in successfulLines.enumerated() {
                    guard let first = line.first else { continue }
                    
                    let starA = stars[lineIndex]
                    let starB = stars[lineIndex + 1]
                    
                    let minX = min(starA.x, starB.x)
                    let maxX = max(starA.x, starB.x)
                    let minY = min(starA.y, starB.y)
                    let maxY = max(starA.y, starB.y)
                    
                    let filteredLine = line.filter { point in
                        (minX...maxX).contains(point.x) && (minY...maxY).contains(point.y)
                    }
                    
                    if !filteredLine.isEmpty {
                        var path = Path()
                        path.move(to: scalePoint(filteredLine.first!, xScale: xScale, yScale: yScale))
                        for point in filteredLine.dropFirst() {
                            path.addLine(to: scalePoint(point, xScale: xScale, yScale: yScale))
                        }
                        context.stroke(path,
                                       with: .color(.cyan),
                                       style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                }
                
                // --- Layer 3: Current preview line ---
                if let first = currentLine.first {
                    var path = Path()
                    path.move(to: scalePoint(first, xScale: xScale, yScale: yScale))
                    for point in currentLine.dropFirst() {
                        path.addLine(to: scalePoint(point, xScale: xScale, yScale: yScale))
                    }
                    context.stroke(path,
                                   with: .color(.white.opacity(0.5)),
                                   style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                }
                
            }
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            
            // --- Stars overlay ---
            GeometryReader { geo in
                let xScale = geo.size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                let yScale = geo.size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
                
                ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                    let p = scalePoint((Double(star.x), Double(star.y)), xScale: xScale, yScale: yScale)
                    let screenX = p.x + geo.size.width / 2
                    let screenY = p.y + geo.size.height / 2
                    
                    ZStack {
                        Button(action: {
                            selectedStarIndex = index
                        }) {
                            Circle()
                                .fill(
                                    connectedStarIndices.contains(index) ? Color.blue :
                                    (index == currentTargetIndex || index == currentTargetIndex + 1
                                     ? Color.yellow
                                     : Color.white.opacity(0.7))
                                )
                                .frame(width: 10, height: 10)
                        }
                        
                        if selectedStarIndex == index {
                            Text("(\(Int(star.x)), \(Int(star.y)))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(6)
                                .offset(y: -25)
                        }
                    }
                    .position(x: screenX, y: screenY)
                }
            }
        }
    }
    
    // MARK: - Helper: Scale model coords → screen coords
    private func scalePoint(_ point: (x: Double, y: Double), xScale: CGFloat, yScale: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(point.x) * xScale,
                y: -CGFloat(point.y) * yScale)
    }
    
    // MARK: - Helper: Draw grid lines
    private func drawGrid(context: GraphicsContext, size: CGSize, xScale: CGFloat, yScale: CGFloat) {
        var grid = Path()
        
        // Vertical lines
        for x in Int(xRange.lowerBound)...Int(xRange.upperBound) {
            let px = CGFloat(x) * xScale
            grid.move(to: CGPoint(x: px, y: -size.height/2))
            grid.addLine(to: CGPoint(x: px, y: size.height/2))
        }
        
        // Horizontal lines
        for y in Int(yRange.lowerBound)...Int(yRange.upperBound) {
            let py = CGFloat(y) * yScale
            grid.move(to: CGPoint(x: -size.width/2, y: -py))
            grid.addLine(to: CGPoint(x: size.width/2, y: -py))
        }
        
        context.stroke(grid, with: .color(.gray.opacity(0.2)), lineWidth: 1)
    }
}

