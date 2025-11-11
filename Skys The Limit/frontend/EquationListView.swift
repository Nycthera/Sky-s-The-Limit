import SwiftUI

struct EquationListView: View {
    @EnvironmentObject var equationStore: EquationStore
    @State private var latexString = "y=x^{2}"
    @State private var graphPoints: [(x: Double, y: Double)] = []

    // This sets the appearance for the navigation bar.
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        VStack(spacing: 15) {
            // Live-rendering display area
            MathView(equation: latexString, fontSize: 40)
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            // Live-rendering graph view
            GraphCanvasView(points: graphPoints)
                .frame(height: 250)

            // The custom keyboard component
            MathKeyboardView(latexString: $latexString)
            
            Button("Save To Galaxy") {
                equationStore.saveEquation(latex: latexString)
            }
            .font(.custom("SpaceMono-Regular", size: 20))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(15)
        }
        .padding()
        .background(
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
        )
        .onChange(of: latexString) { _, newLatex in
            updateGraph()
        }
        .onAppear {
            updateGraph()
        }
        .navigationTitle("Draw The Stars")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updateGraph() {
        let engineFormattedString = latexToEngineFormat(latexString)
        let engine = MathEngine(equation: engineFormattedString)
        if engine.isValid() {
            self.graphPoints = engine.calculatePoints()
        } else {
            self.graphPoints = []
        }
    }
    
    private func latexToEngineFormat(_ latex: String) -> String {
        return latex
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "{", with: "(")
            .replacingOccurrences(of: "}", with: ")")
            .replacingOccurrences(of: "frac(a)(b)", with: "(a)/(b)")
    }
}

#Preview {
    NavigationView {
        EquationListView()
            .environmentObject(EquationStore())
    }
}
