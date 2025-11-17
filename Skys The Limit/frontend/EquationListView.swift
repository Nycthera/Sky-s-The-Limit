import SwiftUI
import SwiftMath

struct EquationListView: View {
    @StateObject private var viewModel = EquationPuzzleViewModel()
    @EnvironmentObject var equationStore: EquationStore
    
    @State private var currentMathString: String = ""
    @State private var isSidebarCollapsed: Bool = false

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    SidebarView(
                        isCollapsed: isSidebarCollapsed,
                        width: geometry.size.width * 0.20,
                        stars: viewModel.stars,
                        successfulEquations: viewModel.successfulEquations
                    )

                    GameAreaView(
                        viewModel: viewModel,
                        currentMathString: $currentMathString,
                        canvasHeight: geometry.size.height * 0.18
                    )
                    .padding()
                }
                .overlay(alignment: .leading) {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isSidebarCollapsed.toggle()
                        }
                    }) {
                        Image(systemName: isSidebarCollapsed
                              ? "arrow.right.circle.fill"
                              : "arrow.left.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                        .padding(10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .padding(.leading, 6)
                    }
                }
            }

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
            print("somt heere")
        }
        .navigationTitle("Draw The Stars")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
}

private struct SidebarView: View {
    let isCollapsed: Bool
    let width: CGFloat
    let stars: [CGPoint]
    let successfulEquations: [String]

    var body: some View {
        VStack(spacing: 12) {
            if !isCollapsed {
                Text("Equations")
                    .font(.custom("SpaceMono-Bold", size: 24))
                    .foregroundColor(.white)

                Text("Target Coordinates")
                    .font(.custom("SpaceMono-Bold", size: 18))
                    .foregroundColor(.yellow)

                ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                    Text("Star \(index + 1): (\(Int(star.x)), \(Int(star.y)))")
                        .font(.custom("SpaceMono-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(5)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(successfulEquations, id: \.self) { equation in
                            MathView(
                                equation: equation,
                                textAlignment: .left,
                                fontSize: 22
                            )
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical)
        .padding(.trailing, 8)
        .frame(width: isCollapsed ? 0 : width)
        .clipped()
        .background(isCollapsed ? Color.clear : Color.black.opacity(0.4))
        .animation(.easeInOut, value: isCollapsed)
    }
}

private struct GameAreaView: View {
    @ObservedObject var viewModel: EquationPuzzleViewModel
    @Binding var currentMathString: String
    let canvasHeight: CGFloat

    var body: some View {
        VStack(spacing: 15) {
            if !viewModel.isPuzzleComplete &&
                viewModel.stars.count > viewModel.currentTargetIndex + 1 {

                Text("Connect Star \(viewModel.currentTargetIndex + 1) → Star \(viewModel.currentTargetIndex + 2)")
                    .font(.custom("SpaceMono-Regular", size: 20))
                    .foregroundColor(.yellow)
            }

            GraphCanvasView(
                stars: viewModel.stars,
                successfulLines: viewModel.successfulLines,
                currentLine: viewModel.currentGraphPoints,
                currentTargetIndex: viewModel.currentTargetIndex,
                connectedStarIndices: viewModel.connectedStarIndices
            )
            .frame(height: canvasHeight)

            MathView(
                equation: viewModel.currentLatexString,
                fontSize: 22
            )
            .frame(maxWidth: .infinity, minHeight: 10, maxHeight: 20)
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)

            MathKeyboardView(
                latexString: $viewModel.currentLatexString,
                mathString: $currentMathString
            )

            Button("Check Line") {
                viewModel.checkCurrentLineSolution()
                viewModel.updateUserGraph()
            }
            .font(.custom("SpaceMono-Regular", size: 20))
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(15)
            .disabled(viewModel.isPuzzleComplete)
        }
    }
}
