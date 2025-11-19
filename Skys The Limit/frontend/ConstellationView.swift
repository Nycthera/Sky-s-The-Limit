import SwiftUI
import SwiftMath

struct ConstellationView: View {
    @EnvironmentObject var equationStore: EquationStore
    
    @State private var showModal = false
    @State private var constellationName = ""
    @State private var numberOfStars: Int? = nil
    @State private var isShared = false
    
    // Track selected constellation to show in canvas
    @State private var selectedConstellation: Constellation? = nil
    
    // Store constellation rows from Appwrite
    @State private var constellations: [Constellation] = []
    
    let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    
    // 2-column flexible grid
    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            Image("Space")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(constellations) { constellation in
                        VStack(spacing: 12) {
                            Text(constellation.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("\(constellation.equations.count) equations")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            if constellation.isShared {
                                Text("Shared")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(
                            Color.white.opacity(0.1)
                                .background(.ultraThinMaterial)
                                .blur(radius: 1)
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        // <-- Tapping a box opens canvas
                        .onTapGesture {
                            selectedConstellation = constellation
                        }
                    }
                }
                .padding()
            }
            
            Button {
                print("Add pressed")
                showModal = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(20)
            .sheet(isPresented: $showModal) {
                ConstellationModalView(
                    name: $constellationName,
                    numberOfStars: Binding(
                        get: { numberOfStars.map(String.init) ?? "" },
                        set: { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                            if trimmed.isEmpty {
                                numberOfStars = nil
                            } else if let intVal = Int(trimmed) {
                                numberOfStars = intVal
                            }
                        }
                    ),
                    isShared: $isShared
                )
            }
        }
        // <-- Full screen cover to show the selected constellation
        .fullScreenCover(item: $selectedConstellation) { constellation in
            // Convert equations to points via MathEngine
            let points = constellation.equations.flatMap { eqStr -> [(x: Double, y: Double)] in
                let engine = MathEngine(equation: eqStr)
                return engine.evaluate() ?? []
            }
            
            // Build a list of lines (for simplicity, each consecutive point in array)
            let lines: [[(x: Double, y: Double)]] = points.chunked(into: 2)
            
            CustomConstellationView(
                stars: points.map { CGPoint(x: $0.x, y: $0.y) },
                successfulLines: lines,
                currentLine: [],
                currentTargetIndex: 0,
                connectedStarIndices: []
            )
        }
        .onAppear {
            Task {
                await loadConstellations()
            }
        }
    }
    
    // MARK: - Load all documents from Appwrite
    func loadConstellations() async {
        await list_document_for_user()
        
        var fetched: [Constellation] = []
        
        for id in userTableIDs {
            if let doc = await get_document_for_user(rowId: id) {
                fetched.append(doc)
            }
        }
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.constellations = fetched
        }
    }
}

// Helper extension for chunking arrays into consecutive pairs
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var chunks: [[Element]] = []
        var index = 0
        while index < count {
            let end = Swift.min(index + size, count)
            chunks.append(Array(self[index..<end]))
            index += size
        }
        return chunks
    }
}

#Preview {
    ConstellationView()
        .environmentObject(EquationStore())
}
