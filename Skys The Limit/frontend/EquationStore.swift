//
//  EquationStore.swift
//  Skys The Limit
//
//  Created by Chris  on 17/11/25.
//

import Foundation
import SwiftUI
import Combine
@MainActor
class EquationStore: ObservableObject {
    
    @Published var equations: [String] = []

    init() { }
    
    func saveEquation(latex: String) {
        if !equations.contains(latex) {
            equations.append(latex)
        }
        
        Task {
            // 1. First, check the database for this user's documents.
            await list_document_for_user()
            
            // 2. Now, call the update function. It will handle both
            //    updating an existing document or creating a new one.
            await update_document_for_user(equations: self.equations)
        }
    }
    
    // You can build this out later to load saved data from the database.
    func fetchEquations() async {
        print("Fetching equations from database...")
        // await list_document_for_user()
        // ... then add logic to get the row and decode the equations array.
    }
}
