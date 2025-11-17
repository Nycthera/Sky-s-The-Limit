import SwiftUI

struct GraphCanvasView: View {
    //guys this is for the animation drawing 
    @State private var animationProgress: Double = 1.0
    
    let stars: [CGPoint]
    let successfulLines: [[(x: Double, y: Double)]]
    let currentLine: [(x: Double, y: Double)]
    let currentTargetIndex: Int

    private let xRange: ClosedRange<Double> = -10...10
    private let yRange: ClosedRange<Double> = -10...10
    
    var body: some View {
        Canvas { context, size in
            let xScale = size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
            let yScale = size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
            
            context.translateBy(x: size.width / 2, y: size.height / 2)

            // Layer 1: Axes
            var axes = Path()
            axes.move(to: CGPoint(x: -size.width / 2, y: 0))
            axes.addLine(to: CGPoint(x: size.width / 2, y: 0))
            axes.move(to: CGPoint(x: 0, y: -size.height / 2))
            axes.addLine(to: CGPoint(x: 0, y: size.height / 2))
            context.stroke(axes, with: .color(.gray.opacity(0.4)), lineWidth: 1)
            
            // Layer 2: Completed lines
            for line in successfulLines {
                if line.isEmpty { continue }
                var path = Path()
                path.move(to: scale(point: line.first!, xScale: xScale, yScale: yScale))
                for point in line.dropFirst() {
                    path.addLine(to: scale(point: point, xScale: xScale, yScale: yScale))
                }
                context.stroke(path, with: .color(.cyan), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
            
            // Layer 3: Current preview line
            if !currentLine.isEmpty {
                var path = Path()
                path.move(to: scale(point: currentLine.first!, xScale: xScale, yScale: yScale))
                for point in currentLine.dropFirst() {
                    path.addLine(to: scale(point: point, xScale: xScale, yScale: yScale))
                }
                context.stroke(path, with: .color(.white.opacity(0.5)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
            }
            
            // Layer 4: Stars and highlights
            for (index, star) in stars.enumerated() {
                let screenPoint = scale(point: star, xScale: xScale, yScale: yScale)
                let rect = CGRect(x: screenPoint.x - 5, y: screenPoint.y - 5, width: 10, height: 10)
                
                if index == currentTargetIndex || index == currentTargetIndex + 1 {
                    let highlightRect = CGRect(x: screenPoint.x - 10, y: screenPoint.y - 10, width: 20, height: 20)
                    context.stroke(Path(ellipseIn: highlightRect), with: .color(.yellow.opacity(0.8)), lineWidth: 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.yellow))
                } else {
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.7)))
                }
            }
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func scale(point: (x: Double, y: Double), xScale: CGFloat, yScale: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(point.x) * xScale, y: -CGFloat(point.y) * yScale)
    }
    
    private func scale(point: CGPoint, xScale: CGFloat, yScale: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * xScale, y: -point.y * yScale)
    }
}
