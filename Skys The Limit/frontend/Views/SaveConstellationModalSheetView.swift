
import SwiftUI

struct SaveConstellationModalSheetView: View {
    @Binding var name: String
     var onSubmit: () -> Void
     @Environment(\.dismiss) var dismiss
     
    var body: some View {
        NavigationView {
                    Form {
                        Section("Name Your Constellation") {
                            TextField("e.g. Orion II", text: $name)
                        }
                    }
                    .navigationTitle("Save Constellation")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if !name.isEmpty {
                                    onSubmit()
                                    dismiss()
                                }
                            }
                            .onAppear(){
                                print(name)
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dismiss() }
                        }
                    }
                }
            }
    }

#Preview {
    SaveConstellationModalSheetView(
        name: .constant(""),
        onSubmit: { }
    )
}
