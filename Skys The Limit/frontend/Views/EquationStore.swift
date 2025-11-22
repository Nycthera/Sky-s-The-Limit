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
    
    // You can build this out later to load saved data from the database.
    func fetchEquations() async {
        print("Fetching equations from database...")
        // await list_document_for_user()
        // ... then add logic to get the row and decode the equations array.
    }
}
