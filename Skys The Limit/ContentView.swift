//
//  ContentView.swift
//  Skys The Limit
//
//  Created by Chris on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Hi")
        }
        .padding()
        .onAppear {

            let equationInput = "y = ax^2 + bx + c"
            let engine = MathEngine(equation: equationInput)

            print("Input Equation: \(equationInput)")

            // Validate
            guard engine.isValid() else {
                print("Invalid equation format!")
                return
            }

            // Detect type
            let type = engine.detectType()
            print("Equation Type Detected: \(type.rawValue)\n")

            // Evaluate
            if let points = engine.evaluate() {
                print("Generated Points:")
                for point in points {
                    print(String(format: "x = %.2f, y = %.2f", point.x, point.y))
                }
            } else {
                print("Could not evaluate the equation.")
            }
        }
    }
}

#Preview {
    ContentView()
}
