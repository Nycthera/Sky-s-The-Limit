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
                for line in successfulLines {
                    guard let first = line.first else { continue }
                    var path = Path()
                    path.move(to: scalePoint(first, xScale, yScale))
                    for point in line.dropFirst() {
                        path.addLine(to: scalePoint(point, xScale, yScale))
                    }
                    context.stroke(path, with: .color(.cyan), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }

                // --- Layer 3: Current preview line ---
                if let first = currentLine.first {
                    var path = Path()
                    path.move(to: scalePoint(first, xScale, yScale))
                    for point in currentLine.dropFirst() {
                        path.addLine(to: scalePoint(point, xScale, yScale))
                    }
                    context.stroke(path,
                                   with: .color(.white.opacity(0.5)),
                                   style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                }

                // --- Layer 4: Stars ---
                for (index, star) in stars.enumerated() {
                    let p = scalePoint((Double(star.x), Double(star.y)), xScale, yScale)

                    let starRect = CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10)

                    if index == currentTargetIndex || index == currentTargetIndex + 1 {
                        let highlight = CGRect(x: p.x - 12, y: p.y - 12, width: 24, height: 24)
                        context.stroke(Path(ellipseIn: highlight), with: .color(.yellow.opacity(0.8)), lineWidth: 2)
                        context.fill(Path(ellipseIn: starRect), with: .color(.yellow))
                    } else {
                        context.fill(Path(ellipseIn: starRect), with: .color(.white.opacity(0.7)))
                    }
                }
            }
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
        }
    }

    // MARK: - Helper: Scale model coords → screen coords
    private func scalePoint(_ point: (x: Double, y: Double), _ xScale: CGFloat, _ yScale: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(point.x) * xScale,
                y: -CGFloat(point.y) * yScale)
    }

    // MARK: - Helper: Draw grid lines
    private func drawGrid(context: GraphicsContext, size: CGSize, xScale: CGFloat, yScale: CGFloat) {
        var grid = Path()

        // Vertical lines for each x integer
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
