//
//  FadeShowView.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 15/11/25.
//
import SwiftUI

struct FadeShowView: View {
    @State private var showFirst = true
    @State private var opacityA = 1.0
    @State private var opacityB = 0.0

    var body: some View {
        ZStack {
            AnimationView()
                .opacity(opacityA)

            MainMenuView()
                .opacity(opacityB)
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.5)) {
                opacityA = 0     // fade out first
                opacityB = 1     // fade in second
            }
        }
    }
}

#Preview {
    FadeShowView()
}
