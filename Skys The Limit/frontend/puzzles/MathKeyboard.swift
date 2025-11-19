import SwiftUI

// MARK: - Key Types
enum KeyType {
    case character
    case backspace
}

// MARK: - Math Key
struct MathKey: Identifiable, Hashable {
    let id = UUID()
    let display: String   // What is shown on the button
    let mathValue: String // Used in MathEngine
    let type: KeyType
    // removed `width: GridItem.Size` because GridItem.Size is NOT Hashable
}

// MARK: - Math Keyboard View
struct MathKeyboardView: View {

    @Binding var latexString: String
    @Binding var mathString: String

    // MARK: - Keyboard Layout
    private let keyboardRows: [[MathKey]] = [
        [
            MathKey(display: "1", mathValue: "1", type: .character),
            MathKey(display: "2", mathValue: "2", type: .character),
            MathKey(display: "3", mathValue: "3", type: .character)
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
            MathKey(display: ".", mathValue: ".", type: .character),
            MathKey(display: "/", mathValue: "/", type: .character)
        ],
        [
            MathKey(display: "x²", mathValue: "^2", type: .character),
            MathKey(display: "√", mathValue: "sqrt(", type: .character),
            MathKey(display: "⌫", mathValue: "", type: .backspace),
            MathKey(display: "+", mathValue: "+", type: .character),
            MathKey(display: "-", mathValue: "-", type: .character),
            MathKey(display: "=", mathValue: "=", type: .character)
        ]
    ]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            ForEach(keyboardRows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row) { key in
                        Button(action: { handleKeyPress(key) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(key.type == .backspace
                                          ? Color.red.opacity(0.75)
                                          : Color.white.opacity(0.12))
                                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)

                                Text(key.display)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(height: 52)
                            .accessibilityLabel(accessibilityLabel(for: key))
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .padding(.horizontal, 10)
    }

    // MARK: - Key Press Logic
    private func handleKeyPress(_ key: MathKey) {
        switch key.type {
        case .character:
            latexString += key.display
            mathString += key.mathValue

        case .backspace:
            if !latexString.isEmpty { latexString.removeLast() }
            if !mathString.isEmpty { mathString.removeLast() }
        }
    }

    private func accessibilityLabel(for key: MathKey) -> String {
        switch key.type {
        case .backspace: return "Backspace"
        case .character: return key.display
        }
    }
}
