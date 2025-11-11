//
//  GraphCanvasView 2.swift
//  Skys The Limit
//
//  Created by Nhavin Thirukkumaran on 11/11/25.
//


import SwiftUI

struct GraphCanvasView: View {
    let points: [(x: Double, y: Double)]
    
    // Define the visible range of your graph
    let xRange: ClosedRange<Double> = -10...10
    let yRange: ClosedRange<Double> = -10...10
    
    var body: some View {
        Canvas { context, size in
            // --- Coordinate Transformation ---
            let xScale = size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
            let yScale = size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
            
            // Move origin to the center
            context.translateBy(x: size.width / 2, y: size.height / 2)

            // --- Draw Axes ---
            var axes = Path()
            axes.move(to: CGPoint(x: -size.width / 2, y: 0))
            axes.addLine(to: CGPoint(x: size.width / 2, y: 0)) // X-axis
            axes.move(to: CGPoint(x: 0, y: -size.height / 2))
            axes.addLine(to: CGPoint(x: 0, y: size.height / 2)) // Y-axis
            context.stroke(axes, with: .color(.gray.opacity(0.5)), lineWidth: 1)
            
            // --- Draw Graph Line ---
            if !points.isEmpty {
                var path = Path()
                
                // Scale the first point and move to it
                let firstPoint = points[0]
                let startX = CGFloat(firstPoint.x) * xScale
                let startY = -CGFloat(firstPoint.y) * yScale // Invert Y for screen coordinates
                path.move(to: CGPoint(x: startX, y: startY))
                
                // Add a line to each subsequent point
                for point in points.dropFirst() {
                    let nextX = CGFloat(point.x) * xScale
                    let nextY = -CGFloat(point.y) * yScale
                    path.addLine(to: CGPoint(x: nextX, y: nextY))
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
        }
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}