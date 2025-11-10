//
//  MathKeyboardView.swift
//  Sky's The Limit
//
//  Created by Nhavin Thirukkumaran on 7/11/25.
//

import SwiftUI



// An enum to define the behavior of a key
enum KeyType {
    case character
    case backspace
}

// A struct to represent a single, identifiable key on our keyboard
struct MathKey: Identifiable {
    let id = UUID()
    let display: String   // What the user sees on the button (e.g., "√")
    let latex: String     // The LaTeX string to insert (e.g., "\\sqrt{}")
    let type: KeyType
}



// This view is the keyboard itself. It is designed to be a reusable component.
struct MathKeyboardView: View {
    // This binding allows the keyboard to modify a String that lives in a different view.
    // This is how the keyboard communicates its changes back to the main screen.
    @Binding var latexString: String

    
    let keyboardLayout: [[MathKey]] = [
        // Row 1: Numbers and Parentheses
        [
            MathKey(display: "1", latex: "1", type: .character),
            MathKey(display: "2", latex: "2", type: .character),
            MathKey(display: "3", latex: "3", type: .character),
            MathKey(display: "(", latex: "(", type: .character),
            MathKey(display: ")", latex: ")", type: .character)
        ],
        // Row 2: More Numbers and Variables
        [
            MathKey(display: "4", latex: "4", type: .character),
            MathKey(display: "5", latex: "5", type: .character),
            MathKey(display: "6", latex: "6", type: .character),
            MathKey(display: "x", latex: "x", type: .character),
            MathKey(display: "y", latex: "y", type: .character)
        ],
        // Row 3: Final Numbers and Comma
        [
            MathKey(display: "7", latex: "7", type: .character),
            MathKey(display: "8", latex: "8", type: .character),
            MathKey(display: "9", latex: "9", type: .character),
            MathKey(display: "0", latex: "0", type: .character),
            MathKey(display: ",", latex: ",", type: .character)
        ],
        // Row 4: Functions and Backspace
        [
            MathKey(display: "a/b", latex: "\\frac{}{}", type: .character),
            MathKey(display: "x²", latex: "^{2}", type: .character),
            MathKey(display: "√", latex: "\\sqrt{}", type: .character),
            MathKey(display: "⌫", latex: "", type: .backspace) // The backspace key
        ]
    ]

    var body: some View {
        VStack(spacing: 10) {
            // Loop through each row in our layout
            ForEach(keyboardLayout, id: \.first!.id) { row in
                HStack(spacing: 10) {
                    // Loop through each key in the current row
                    ForEach(row) { key in
                        Button {
                            // When a key is pressed, call our handler function
                            handleKeyPress(key)
                        } label: {
                            Text(key.display)
                                .font(.system(size: 22, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(key.type == .backspace ? Color.red.opacity(0.7) : Color.gray.opacity(0.25))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }

   
    private func handleKeyPress(_ key: MathKey) {
        switch key.type {
        case .character:
            // If it's a normal character, just append its LaTeX string
            latexString += key.latex
            
        case .backspace:
            // If it's a backspace, remove the last character, but only if the string isn't empty
            if !latexString.isEmpty {
                latexString.removeLast()
            }
        }
    }
}


