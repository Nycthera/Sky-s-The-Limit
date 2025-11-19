import SwiftUI
import SwiftMath

struct ConstellationView: View {
    @EnvironmentObject var equationStore: EquationStore
    @State private var haveConstellations: Bool = false
    @State private var showModal = false
    @State private var constellationName = ""
    @State private var numberOfStars: Int? = nil
    @State private var isShared = false
    let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) { // Align button easily
            // Background
            Image("Space")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Button on bottom-right
            Button {
                print("Pressed")
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
                    numberOfStars: Binding<String>(
                        get: { numberOfStars.map(String.init) ?? "" },
                        set: { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            if trimmed.isEmpty {
                                numberOfStars = nil
                            } else if let value = Int(trimmed) {
                                numberOfStars = value
                            } else {
                                // Keep previous value if input isn't a valid integer
                            }
                        }
                    ),
                    isShared: $isShared
                )
            }
        }
    }
}

#Preview {
    ConstellationView()
        .environmentObject(EquationStore())
}
