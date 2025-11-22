//
//  ConfettiType.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 19/11/25.
//

import UIKit
import SwiftUI

class ConfettiType {
    let color: UIColor
    let shape: ConfettiShape
    let position: ConfettiPosition
    
    init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
        self.color = color
        self.shape = shape
        self.position = position
    }
    
    lazy var image: UIImage = {
    
        let imageRect: CGRect = {
            switch shape {
            case .rectangle:
                return CGRect(x: 0, y: 0, width: 4, height: 3)
            case .triangle:
                    return CGRect(x: 0, y: 0, width: 4, height: 3)
            case .circle:
                    return CGRect(x: 0, y: 0, width: 3, height: 3)
                
            }
        }()
        
        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        
        return renderer.image { rendererContext in
            
            let context = rendererContext.cgContext
            
            context.setFillColor(color.cgColor)
            
            switch shape {
            case . rectangle:
                context.fill(imageRect)
            case . triangle:
                let path = CGMutablePath()
                path.move(to: CGPoint(x: imageRect.midX, y: imageRect.minY))
                path.addLine(to: CGPoint(x: imageRect.maxX, y: imageRect.maxY))
                path.addLine(to: CGPoint(x: imageRect.minX, y: imageRect.maxY))
                path.closeSubpath()
                
                context.addPath(path)
                context.fillPath()
           
            case .circle:
                context.fillEllipse(in: imageRect )
            }
        }
    }()
}

enum ConfettiShape {
    case rectangle
    case triangle
    case circle
    
    static var allCases: [ConfettiShape] {
        return [.rectangle, .triangle, .circle]
    }
}


enum ConfettiPosition {
    case foreground
    case background
    
    static var allCases: [ConfettiPosition] {
        return [.foreground, .background]
    }
}
