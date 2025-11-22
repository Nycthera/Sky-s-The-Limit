import SwiftUI
import SwiftMath

//needs to be dismissable

struct ConstellationView: View {
    @State private var showModal = false
    @State private var constellationName = ""
    @State private var numberOfStars: Int? = nil
    @State private var isShared = false
    
    // Track selected constellation to show in canvas
    @State private var selectedConstellation: Constellation? = nil
    
    // Store constellation rows from Appwrite
    @State private var constellations: [Constellation] = []
    
    // NEW: delete states
    @State private var showDeleteAlert = false
    @State private var constellationToDelete: Constellation? = nil
    
    let deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    
    // 2-column flexible grid
    private static let gridColumns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            Image("Space")
                .resizable()
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: Self.gridColumns, spacing: 20) {
                    ForEach(constellations) { constellation in
                        ConstellationCellView(constellation: constellation)
                            .onTapGesture {
                                selectedConstellation = constellation
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                constellationToDelete = constellation
                                showDeleteAlert = true
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
            CustomConstellationView(ID: constellation.id)
        }
        
        // NEW: Delete alert
        .alert("Delete Constellation?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    if let c = constellationToDelete {
                        await deleteConstellation(id: c.id)
                        await loadConstellations()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete “\(constellationToDelete?.name ?? "")”?")
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
    
    // MARK: - Delete document
    func deleteConstellation(id: String) async {
        await delete_document(rowId: id)
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

private struct ConstellationCellView: View {
    let constellation: Constellation

    var body: some View {
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ConstellationView()
}
