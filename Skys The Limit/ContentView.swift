//
//  ContentView.swift
//  Skys The Limit
//
//  Created by Chris on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMenuView()
            .task { @MainActor in
                print("posting to db")
                await post_to_database()
                
                print("querying")
                await list_document_for_user()
            }
    }
}

#Preview {
    ContentView()
}
