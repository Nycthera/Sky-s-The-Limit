import SwiftUI
import SwiftMath

struct EquationListView: View {
    @StateObject private var viewModel = EquationPuzzleViewModel()
    @EnvironmentObject var equationStore: EquationStore
    
    // Safe math string for evaluation (bind to MathKeyboardView)
    @State private var currentMathString: String = ""

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                
                HStack(spacing: 15) {
                    // --- LEFT COLUMN: Equations List ---
                    VStack(spacing: 10) {
                        Text("Equations")
                            .font(.custom("SpaceMono-Bold", size: 24))
                            .foregroundColor(.white)
                        Text("Target Coordinates")
                            .font(.custom("SpaceMono-Bold", size: 18))
                            .foregroundColor(.yellow)
                            .padding(.bottom, 5)
                        ForEach(Array(viewModel.stars.enumerated()), id: \.offset) { index, star in
                            Text("Star \(index + 1): (\(Int(star.x)), \(Int(star.y)))")
                                .font(.custom("SpaceMono-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(5)
                        } // it works by essentially making a text block and displays the respective coordinates. The text is white with the space mono reg font.  and should be to able to fill the column from the left side
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.successfulEquations, id: \.self) { equation in
                                    MathView(equation: equation,
                                             textAlignment: .left,
                                             fontSize: 22)
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(15)
                    // .frame(width: geometry.size.width * 0.35) // Fixed width for left column
                    
                    // --- RIGHT COLUMN: Interactive Area ---
                    VStack(spacing: 15) {
                        
                        if !viewModel.isPuzzleComplete &&
                            viewModel.stars.count > viewModel.currentTargetIndex + 1 {
                            Text("Connect Star \(viewModel.currentTargetIndex + 1) to Star \(viewModel.currentTargetIndex + 2)")
                                .font(.custom("SpaceMono-Regular", size: 20))
                                .foregroundColor(.yellow)
                                .padding(.vertical, 5)
                        }
                        
                        GraphCanvasView(
                            stars: viewModel.stars,
                            successfulLines: viewModel.successfulLines,
                            currentLine: viewModel.currentGraphPoints,
                            currentTargetIndex: viewModel.currentTargetIndex
                        )
                        .frame(height: geometry.size.height * 0.40)
                        
                        MathView(equation: viewModel.currentLatexString,
                                 fontSize: 22)
                            .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 80)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                        
                        // --- Updated MathKeyboardView ---
                        MathKeyboardView(
                            latexString: $viewModel.currentLatexString, mathString: $currentMathString
                        )
                        
                        Button("Check Line") {
                            // TODO: Initialize MathEngine with a proper equation string, not the store
                            // Use currentMathString for evaluation
                            viewModel.checkCurrentLineSolution()
                            print("check line button pressed")
                            
                        }
                        .font(.custom("SpaceMono-Regular", size: 20))
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .disabled(viewModel.isPuzzleComplete)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            
            // "You Win!" overlay
            if viewModel.isPuzzleComplete {
                VStack {
                    Text("You Win!")
                        .font(.custom("SpaceMono-Bold", size: 36))
                        .foregroundColor(.yellow)
                        .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.7))
            }
        }
        .animation(.default, value: viewModel.isPuzzleComplete)
        .animation(.default, value: viewModel.currentTargetIndex)
        .onChange(of: viewModel.currentLatexString) { _ in
            viewModel.updateUserGraph()
        }
        .navigationTitle("Draw The Stars")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
}
