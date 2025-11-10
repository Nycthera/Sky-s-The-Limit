//
//  ContentView.swift
//  Skys The Limit
//
//  Created by Chris on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("hi")
            .font(.custom("SpaceMono-Regular", size: 18))
            .task { @MainActor in
                print("posting to db")
                await post_to_database()
                
                print("querying")
                await list_document_for_user()
                for family in UIFont.familyNames {
                    print("Family: \(family)")
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("  Font: \(name)")
                    }
                }

            }
    }
}

#Preview {
    ContentView()
}
