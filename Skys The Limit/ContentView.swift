//
//  ContentView.swift
//  Skys The Limit
//
//  Created by Chris on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        EquationListView()
            .task {
                do {
                    print("posting to db")
                    try await post_to_database()
                } catch {
                    print("Error posting to database: \(error)")
                }
                
                do {
                    print("qureying")
                    try await list_document_for_user()
                } catch {
                    print("error: \(error)")
                }
            }
    }
}

#Preview {
    ContentView()
}
