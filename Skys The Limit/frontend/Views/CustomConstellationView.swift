
import SwiftUI
import SwiftMath

struct CustomConstellationView: View {
    @State private var arrayOfEquations: [String] = []
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []

    // Separate strings for display and math engine
    @State private var editingLatexString: String = ""
    @State private var editingMathString: String = ""
    @State private var editingIndex: Int? = nil // nil = new, else edit mode
    @State private var isSidebarCollapsed = false
    @State private var showSaveModal = false // Save modal
    @State private var constellationName: String = ""


    @Environment(\.presentationMode) var presentationMode
    let ID: String
    private let sidebarWidth: CGFloat = 250

    var body: some View {     NavigationView {
            GeometryReader { geo in
                ZStack {
                    // Background
                    Image("Space")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    HStack(spacing: 0) {
                        // Sidebar
                        CustomSidebarView(
                            isCollapsed: isSidebarCollapsed,
                            equations: $arrayOfEquations,
                            editingString: $editingLatexString,
                            editingIndex: $editingIndex
                        )

                        // Game Area
                        VStack(spacing: 15) {
                            // Canvas
                            CustomGraphCanvasView(
                                stars: stars,
                                successfulLines: successfulLines,
                                equations: arrayOfEquations,
                                ID: ID,
                                name: constellationName
                            )

                            .frame(height: geo.size.height * 0.4)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .layoutPriority(1)

                            // Keyboard
                            MathKeyboardView(
                                latexString: $editingLatexString,
                                mathString: $editingMathString
                            )
                            .layoutPriority(1)

                            // Add / Update button
                            Button {
                                guard !editingMathString.isEmpty else { return }
                                if let index = editingIndex {
                                    arrayOfEquations[index] = editingMathString
                                } else {
                                    arrayOfEquations.append(editingMathString)
                                }
                                editingLatexString = ""
                                editingMathString = ""
                                editingIndex = nil
                            } label: {
                                Text(editingIndex != nil ? "Update Equation" : "Add Equation")
                                    .font(.custom("SpaceMono-Regular", size: 20))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(15)
                            }

                            // Current input display
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Current Input:")
                                    .font(.custom("SpaceMono-Bold", size: 16))
                                    .foregroundColor(.white)
                                Text(editingLatexString.isEmpty ? "(empty)" : editingLatexString)
                                    .font(.custom("SpaceMono-Regular", size: 16))
                                    .foregroundColor(.yellow)
                                    .padding(6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)

                            Spacer(minLength: 0)
                        }
                        .padding()
                        .frame(width: geo.size.width - (isSidebarCollapsed ? 0 : sidebarWidth))
                        .frame(maxHeight: .infinity)                     }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut) { isSidebarCollapsed.toggle() }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 25))
                    }
    }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Save icon
                        Button {
                            showSaveModal = true
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)     }

                        // Back button
                        Button("Back") { presentationMode.wrappedValue.dismiss() }
                            .font(.custom("SpaceMono-Regular", size: 18))
                            .padding(5)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }  // Save modal
            .sheet(isPresented: $showSaveModal) {
                SaveConstellationModalView(
                    isPresented: $showSaveModal,
                    equations: $arrayOfEquations,
                    existingName: constellationName,
                    docID: ID
                )
            }


            .onAppear {
                Task {
                    if let constellation: Constellation = await get_document_for_user(rowId: ID) {
                        self.arrayOfEquations = constellation.equations
                        self.constellationName = constellation.name   // <-- THE MISSING LINE
                       //TESTING
                        print("Loaded name:", constellation.name)

                    }
                }
            }

            // Auto-update canvas whenever equations change
            .onChange(of: arrayOfEquations) { _ in
                updateStarsFromEquations()
            }
        }
        .navigationViewStyle(.stack)
    }
    // MARK: - Update stars from equations
    private func updateStarsFromEquations() {
        stars = []
        successfulLines = []

        for eq in arrayOfEquations {
            let engine = MathEngine(equation: eq)
            guard let points = engine.evaluate(), !points.isEmpty else { continue }

            // Add points to stars
            stars.append(contentsOf: points.map { CGPoint(x: $0.x, y: $0.y) })

            // Each equation is one "line"
            successfulLines.append(points)
        }
    }

}
// MARK: - Sidebar
private struct CustomSidebarView: View {
    let isCollapsed: Bool
    @Binding var equations: [String]
    @Binding var editingString: String
    @Binding var editingIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isCollapsed {
                Text("Equations")
                    .font(.custom("SpaceMono-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(equations.indices, id: \.self) { idx in
                            MathView(
                                equation: equations[idx],
                                textAlignment: .left,
                                fontSize: 20
                            )
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                editingString = equations[idx]
                                editingIndex = idx
                            }
                            .onLongPressGesture {
                                withAnimation {
                                    equations.remove(at: idx)
                                    if editingIndex == idx {
                                        editingString = ""
                                        editingIndex = nil
                                    } else if let current = editingIndex, current > idx {
                                        editingIndex = current - 1
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }

                // Input for new equation / edit
                VStack(spacing: 5) {
                    Text("New Equation / Edit:")
                        .font(.custom("SpaceMono-Bold", size: 16))
                        .foregroundColor(.white)

                    TextField("Type here...", text: $editingString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 8)
                        .font(.custom("SpaceMono-Regular", size: 16))
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 8)
            }

            Spacer()
        }
        .frame(width: isCollapsed ? 0 : 250)
        .clipped()
        .background(isCollapsed ? Color.clear : Color.black.opacity(0.4))
    }
}
