//
//  CustomGraphCanvasView.swift
//  Skys The Limit
//
//  Created by Chris on 19/11/25.
//

import Foundation
import SwiftUI

struct DocFormat: Codable, Identifiable {
    let id: String
    let userid: String
    let equations: [String]?
    let isShared: Bool
    let createdAt: Date?
    let updatedAt: Date?
    let name: String
}

struct CustomGraphCanvasView: View {
    
    // Passed from parent
    let stars: [CGPoint]
    let successfulLines: [[(x: Double, y: Double)]]
    let equations: [String]
    let ID: String?        // <-- optional
    let name: String?      // optional
    
    // Local states
    @State private var selectedStarCoordinates: String? = nil
    @State private var selectedStarIndex: Int? = nil
    
    private let xRange: ClosedRange<Double> = -10...10
    private let yRange: ClosedRange<Double> = -10...10
    
    @State private var newConstellationName = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack {

                // ------------------ Canvas Layer ------------------
                Canvas { context, size in
                    
                    let padding: CGFloat = 15 // prevent clipping
                    let xScale = (size.width - 2 * padding) / CGFloat(xRange.upperBound - xRange.lowerBound)
                    let yScale = (size.height - 2 * padding) / CGFloat(yRange.upperBound - yRange.lowerBound)
                    
                    context.translateBy(x: size.width / 2, y: size.height / 2)
                    
                    drawGrid(context: context, size: size, xScale: xScale, yScale: yScale, padding: padding)
                    
                    // Draw axes
                    var axes = Path()
                    axes.move(to: CGPoint(x: -size.width/2 + padding, y: 0))
                    axes.addLine(to: CGPoint(x: size.width/2 - padding, y: 0))
                    axes.move(to: CGPoint(x: 0, y: -size.height/2 + padding))
                    axes.addLine(to: CGPoint(x: 0, y: size.height/2 - padding))
                    context.stroke(axes, with: .color(.white.opacity(0.7)), lineWidth: 2)
                    
                    // ------------------ Connect Stars ------------------
                    if stars.count > 1 {
                        var starPath = Path()
                        let first = scalePoint((Double(stars[0].x), Double(stars[0].y)), xScale, yScale)
                        starPath.move(to: first)
                        
                        for i in 1..<stars.count {
                            let p = scalePoint((Double(stars[i].x), Double(stars[i].y)), xScale, yScale)
                            starPath.addLine(to: p)
                        }
                        
                        // Draw the full line in yellow
                        context.stroke(
                            starPath,
                            with: .color(.yellow),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        
                        // Draw dots only at start and end
                        let dotRadius: CGFloat = 5
                        let startPoint = first
                        let endPoint = scalePoint((Double(stars.last!.x), Double(stars.last!.y)), xScale, yScale)
                        
                        context.fill(
                            Circle().path(in: CGRect(x: startPoint.x - dotRadius, y: startPoint.y - dotRadius, width: dotRadius*2, height: dotRadius*2)),
                            with: .color(.white)
                        )
                        
                        context.fill(
                            Circle().path(in: CGRect(x: endPoint.x - dotRadius, y: endPoint.y - dotRadius, width: dotRadius*2, height: dotRadius*2)),
                            with: .color(.white)
                        )
                    }
                    
                    // Draw completed equation lines
                    for (lineIndex, line) in successfulLines.enumerated() {
                        guard line.first != nil else { continue }

                        let starA = stars[lineIndex]
                        let starB = stars[lineIndex + 1]

                        let minX = min(starA.x, starB.x)
                        let maxX = max(starA.x, starB.x)
                        let minY = min(starA.y, starB.y)
                        let maxY = max(starA.y, starB.y)

                        let filteredLine = line.filter { p in
                            (minX...maxX).contains(p.x) && (minY...maxY).contains(p.y)
                        }

                        if !filteredLine.isEmpty {
                            var path = Path()
                            path.move(to: scalePoint(filteredLine.first!, xScale, yScale))
                            for point in filteredLine.dropFirst() {
                                path.addLine(to: scalePoint(point, xScale, yScale))
                            }

                            // <-- CHANGE .cyan TO .yellow
                            context.stroke(
                                path,
                                with: .color(.yellow),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                        }
                    }

                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                
                // ------------------ Name Label ------------------
                if let name {
                    VStack {
                        Text(name)
                            .font(.custom("SpaceMono-Bold", size: 24))
                            .foregroundColor(.yellow)
                            .shadow(radius: 3)
                            .padding(.top, 8)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                }
                
                // ------------------ Stars Layer (clickable info) ------------------
                ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                    let padding: CGFloat = 15
                    let xScale = (geo.size.width - 2 * padding) / CGFloat(xRange.upperBound - xRange.lowerBound)
                    let yScale = (geo.size.height - 2 * padding) / CGFloat(yRange.upperBound - yRange.lowerBound)
                    let p = scalePoint((Double(star.x), Double(star.y)), xScale, yScale)
                    
                    let screenX = p.x + geo.size.width / 2
                    let screenY = p.y + geo.size.height / 2
                    
                    ZStack {
                        Button {
                            selectedStarIndex = index
                        } label: {
                            Circle()
                                .fill(Color.clear) // removed intermediate white dots
                                .frame(width: 10, height: 10)
                        }
                        
                        if selectedStarIndex == index {
                            Text("(\(Int(star.x)), \(Int(star.y)))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                                .offset(y: -25)
                        }
                    }
                    .position(x: screenX, y: screenY)
                }
            }
        }
        .onAppear {
            print("CustomGraphCanvasView appeared.")
            print("Equations passed:", equations)
            if let ID {
                print("Document ID:", ID)
            }
        }
    }
    
    // MARK: - Scale point
    private func scalePoint(_ point: (x: Double, y: Double), _ xScale: CGFloat, _ yScale: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat(point.x) * xScale,
            y: -CGFloat(point.y) * yScale
        )
    }
    
    // MARK: - Draw Grid
    private func drawGrid(context: GraphicsContext, size: CGSize, xScale: CGFloat, yScale: CGFloat, padding: CGFloat) {
        var grid = Path()
        
        // Vertical lines
        for x in Int(xRange.lowerBound)...Int(xRange.upperBound) {
            let px = CGFloat(x) * xScale
            grid.move(to: CGPoint(x: px, y: -size.height/2 + padding))
            grid.addLine(to: CGPoint(x: px, y: size.height/2 - padding))
        }
        
        // Horizontal lines
        for y in Int(yRange.lowerBound)...Int(yRange.upperBound) {
            let py = CGFloat(y) * yScale
            grid.move(to: CGPoint(x: -size.width/2 + padding, y: -py))
            grid.addLine(to: CGPoint(x: size.width/2 - padding, y: -py))
        }
        
        context.stroke(grid, with: .color(.gray.opacity(0.2)), lineWidth: 1)
    }
}
