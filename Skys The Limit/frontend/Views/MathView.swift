//
//  MathView.swift
//  Skys The Limit
//
//  Created by Chris  on 17/11/25.
//

import Foundation
import SwiftUI
import SwiftMath

struct MathView: UIViewRepresentable {
    var equation: String
    var font: MathFont = .latinModernFont
    var textAlignment: MTTextAlignment = .center
    var fontSize: CGFloat = 30
    var labelMode: MTMathUILabelMode = .display
    var insets: MTEdgeInsets = MTEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

    func makeUIView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        let font = MTFontManager().font(withName: font.rawValue, size: fontSize)
        view.font = font
        view.textAlignment = textAlignment
        view.labelMode = labelMode
        // This is the corrected line:
        view.textColor = UIColor.white // Or UIColor.label for auto light/dark mode
        view.contentInsets = insets
        view.invalidateIntrinsicContentSize()
    }
}
