//
//  ConstellationModalView.swift
//  Skys The Limit
//
//  Created by Chris  on 19/11/25.

// this view is a modal sheet when users want to create a new constellation with the + button in my constellation
// if i could i would name it CreateConstellationModalView

import SwiftUI

struct ConstellationModalView: View {
    @Binding var name: String
    @Binding var numberOfStars: String
    @Binding var isShared: Bool
    @Environment(\.dismiss) var dismiss
    let tempEquation = ["1 = 2", "2, 3"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Constellation Info")) {
                    TextField("Constellation Name", text: $name)
                    TextField("Number of Stars", text: $numberOfStars)
                        .keyboardType(.numberPad)
                    Toggle("Shared with others?", isOn: $isShared)
                }
            }
            .navigationTitle("New Constellation")
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
                
                // Done button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        guard !name.isEmpty && numberOfStars != nil else { return }
                        
                        print("Created: \(name), Stars: \(numberOfStars), Shared: \(isShared)")
                        
                        Task {
                            let userHasNoDocument = await checkIfUserHasDocument()
                            await post_to_database(equations: tempEquation, name: name)

                            dismiss()
                        }
                    }

                }
            }
        }
    }
}

