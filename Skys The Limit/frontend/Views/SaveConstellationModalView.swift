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
    var onCancel: (() -> Void)? = nil
    
    init(
        isPresented: Binding<Bool>,
        equations: Binding<[String]>,
        existingName: String,
        docID: String? = nil,
        onSave: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil

    ) {
        self._isPresented = isPresented
        self._equations = equations
        self.existingName = existingName
        self._constellationName = State(initialValue: existingName)
        self.docID = docID
        self.onSave = onSave
        self.onCancel = onCancel
    }

    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Save Constellation")
                    .font(.custom("SpaceMono-Bold", size: 38)) // increased from 24
                    .padding(.top, 25)
                
                TextField("Enter constellation name", text: $constellationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .font(.custom("SpaceMono-Regular", size: 38)) // increased from 18
                
                Toggle(isOn: $isShared) {
                    Text("Share with others")
                        .font(.custom("SpaceMono-Regular", size: 32)) // increased from 18
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                        onCancel?()
                    }
                    .font(.custom("SpaceMono-Regular", size: 28)) // increased from 18
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    
                    Button("Save") {
                        guard !constellationName.isEmpty else { return }
                        Task {
                            await saveConstellation()
                            onSave?()
                            isPresented = false
                        }
                    }
                    .font(.custom("SpaceMono-Bold", size: 28)) // increased from 18
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveConstellation() async {
        guard !constellationName.isEmpty else { return }
        
        let rowId = docID ?? deviceID
        await update_document(
            rowId: rowId,
            equations: equations,
            name: constellationName
        )
        
        print("Updated constellation '\(constellationName)' with \(equations.count) equations")
    }
}
