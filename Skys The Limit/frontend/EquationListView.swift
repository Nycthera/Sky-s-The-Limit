import SwiftUI

struct EquationListView: View {
    @StateObject private var viewModel = EquationPuzzleViewModel()

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            // --- THE GEOMETRYREADER FIX ---
            // This GeometryReader measures the available screen space (the 'geometry' proxy).
            // We will use its height to calculate explicit frame sizes for our views.
            GeometryReader { geometry in
                
                // --- LEFT COLUMN: Equations List ---
                VStack(spacing: 10) {
                    Text("Equations")
                        .font(.custom("SpaceMono-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.successfulEquations, id: \.self) { equation in
                                MathView(equation: equation, textAlignment: .left, fontSize: 22)
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
                // --- FIX 1: Give the left column a fixed width ---
                // .frame(width: 300)

                // --- RIGHT COLUMN: Interactive Area ---
                VStack(spacing: 15) {
                    
                    if !viewModel.isPuzzleComplete && viewModel.stars.count > viewModel.currentTargetIndex + 1 {
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
                    // --- EXPLICIT HEIGHT ---
                    // We tell the graph to be exactly 40% of the available screen height.
                    // This is a non-negotiable command that fixes the layout.
                    .frame(height: geometry.size.height * 0.40)
                    
                    // The Spacer is no longer needed because we are using explicit heights.
                    
                    MathView(equation: viewModel.currentLatexString, fontSize: 22)
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 80)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)

                    MathKeyboardView(latexString: $viewModel.currentLatexString)
                      //  .frame(height: 240) // The keyboard has a fixed height
                    
                    Button("Check Line") {
                        viewModel.checkCurrentLineSolution()
                    }
                    .font(.custom("SpaceMono-Regular", size: 20))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .disabled(viewModel.isPuzzleComplete)
                    
                    // Add a final spacer to push all content to the top if there's extra room.
                    Spacer()
                }
                .padding()
            }
            
            // The "You Win!" overlay
            if viewModel.isPuzzleComplete {
                // ... (Overlay code remains the same)
            }
        }
        .animation(.default, value: viewModel.isPuzzleComplete)
        .animation(.default, value: viewModel.currentTargetIndex)
        .onChange(of: viewModel.currentLatexString) {
            viewModel.updateUserGraph()
        }
        .navigationTitle("Draw The Stars")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
}
