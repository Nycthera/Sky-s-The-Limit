//
//  ContentView.swift
//  Sky's The Limit
//
//  Created by Chris  on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Hi")
        }
        .padding()
        .onAppear(
            perform: {
                var key = grabApiKey()
                print(key)
                
            }
        )
    }
}

#Preview {
    ContentView()
}

