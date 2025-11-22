import Foundation
import SwiftUI

struct SaveConstellationModalView: View {
    @Binding var isPresented: Bool
    @Binding var equations: [String]
    var existingName: String
    var docID: String? = nil
    var deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    
    @State private var constellationName: String = ""
    @State private var isShared: Bool = false
    
    var onSave: (() -> Void)? = nil
    
    init(
        isPresented: Binding<Bool>,
        equations: Binding<[String]>,
        existingName: String,
        docID: String? = nil,    // <-- optional now
        onSave: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self._equations = equations
        self.existingName = existingName
        self._constellationName = State(initialValue: existingName)
        self.docID = docID
        self.onSave = onSave
    }

    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Save Constellation")
                    .font(.custom("SpaceMono-Bold", size: 24))
                    .padding(.top, 20)
                
                TextField("Enter constellation name", text: $constellationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .font(.custom("SpaceMono-Regular", size: 18))
                
                Toggle(isOn: $isShared) {
                    Text("Share with others")
                        .font(.custom("SpaceMono-Regular", size: 18))
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.custom("SpaceMono-Regular", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("Save") {
                        guard !constellationName.isEmpty else { return }
                        Task {
                            await saveConstellation()
                            onSave?()
                            isPresented = false
                        }
                    }
                    .font(.custom("SpaceMono-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
    
    // async save function
    private func saveConstellation() async {
        guard !constellationName.isEmpty else { return }
        
        let rowId = docID ?? deviceID  // fallback if nil
        await update_document(
            rowId: rowId,
            equations: equations,
            name: constellationName
        )
        
        print("Updated constellation '\(constellationName)' with \(equations.count) equations")
    }
}
