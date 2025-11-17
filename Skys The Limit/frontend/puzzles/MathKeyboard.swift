//
//  MathKeyboardView.swift
//  Skys The Limit
//
//  Created by Nhavin Thirukkumaran on 7/11/25.
//

import SwiftUI

// MARK: - Key Types
enum KeyType: Hashable {
    case character
    case backspace
}

// MARK: - Math Key
struct MathKey: Identifiable, Hashable {
    let id = UUID()
    let display: String   // What the user sees on the button (LaTeX or symbol)
    let mathValue: String // Safe string for MathEngine evaluation
    let type: KeyType
}

// MARK: - Keyboard View
struct MathKeyboardView: View {
    // Displayed LaTeX string (UI)
    @Binding var latexString: String
    // Safe math string (for NSExpression / MathEngine)
    @Binding var mathString: String

    // Keyboard layout
    let keyboardLayout: [[MathKey]] = [
        [
            MathKey(display: "1", mathValue: "1", type: .character),
            MathKey(display: "2", mathValue: "2", type: .character),
            MathKey(display: "3", mathValue: "3", type: .character),
            MathKey(display: "(", mathValue: "(", type: .character),
            MathKey(display: ")", mathValue: ")", type: .character)
        ],
        [
            MathKey(display: "4", mathValue: "4", type: .character),
            MathKey(display: "5", mathValue: "5", type: .character),
            MathKey(display: "6", mathValue: "6", type: .character),
            MathKey(display: "x", mathValue: "x", type: .character),
            MathKey(display: "y", mathValue: "y", type: .character)
        ],
        [
            MathKey(display: "7", mathValue: "7", type: .character),
            MathKey(display: "8", mathValue: "8", type: .character),
            MathKey(display: "9", mathValue: "9", type: .character),
            MathKey(display: "0", mathValue: "0", type: .character),
            MathKey(display: ",", mathValue: ",", type: .character)
        ],
        [
            MathKey(display: "a/b", mathValue: "(", type: .character),  // placeholder for display
            MathKey(display: "x²", mathValue: "^2", type: .character),
            MathKey(display: "√", mathValue: "sqrt(", type: .character),
            MathKey(display: "⌫", mathValue: "", type: .backspace),
            MathKey(display: "=", mathValue: "=", type: .character),
            MathKey(display: "+", mathValue: "+", type: .character),
            MathKey(display: "-", mathValue: "-", type: .character)
        ]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keyboardLayout, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(row) { key in
                        Button {
                            handleKeyPress(key)
                        } label: {
                            Text(key.display)
                                .font(.system(size: 20, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    key.type == .backspace
                                        ? Color.red.opacity(0.7)
                                        : Color.gray.opacity(0.25)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .frame(height: 240)
    }

    // MARK: - Key Handling
    private func handleKeyPress(_ key: MathKey) {
        switch key.type {
        case .character:
            // Append display for LaTeX
            latexString += key.display
            
            // Append safe math string for evaluation
            mathString += key.mathValue

        case .backspace:
            // Remove last character from LaTeX display
            if !latexString.isEmpty {
                latexString.removeLast()
            }
            // Remove last character from math string safely
            if !mathString.isEmpty {
                mathString.removeLast()
            }
        }
    }
}

