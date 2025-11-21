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
    let ID: String
    let name: String?   // <-- new optional property
    
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
                    
                    let xScale = size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                    let yScale = size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
                    
                    context.translateBy(x: size.width / 2, y: size.height / 2)
                    
                    drawGrid(context: context, size: size, xScale: xScale, yScale: yScale)
                    
                    // Draw axes
                    var axes = Path()
                    axes.move(to: CGPoint(x: -size.width/2, y: 0))
                    axes.addLine(to: CGPoint(x: size.width/2, y: 0))
                    axes.move(to: CGPoint(x: 0, y: -size.height/2))
                    axes.addLine(to: CGPoint(x: 0, y: size.height/2))
                    context.stroke(axes, with: .color(.white.opacity(0.7)), lineWidth: 2)
                    
                    // Draw completed lines
                    for (lineIndex, line) in successfulLines.enumerated() {
                        guard let first = line.first else { continue }
                        
                        // Determine line segment bounds
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
                            context.stroke(path,
                                           with: .color(.cyan),
                                           style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                        }
                    }
                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                
                if let name {
                        VStack {
                            Text(name)
                                .font(.custom("SpaceMono-Bold", size: 24))
                                .foregroundColor(.yellow)
                                .shadow(radius: 3)
                                .padding(.top, 8)
                            Spacer() // pushes name to top
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false) // ensures it doesn’t block star taps
                    }
                
                // ------------------ Stars Layer ------------------
                ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                    let xScale = geo.size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                    let yScale = geo.size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
                    let p = scalePoint((Double(star.x), Double(star.y)), xScale, yScale)
                    
                    let screenX = p.x + geo.size.width / 2
                    let screenY = p.y + geo.size.height / 2
                    
                    ZStack {
                        Button {
                            selectedStarIndex = index
                        } label: {
                            Circle()
                                .fill(Color.white.opacity(0.8))
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
