//
//  AnimationView.swift
//  Meteor Animation
//
//  Created by Hailey Tan on 15/11/25.
//

import SwiftUI

struct AnimationView: View {
   @State private var reactionCount: Int = 0
    @State private var showText = false

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .onAppear(){
                    reactionCount += 1
                    showText = true
                }

            VStack {
                Image("Meteor")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 90, y: -100)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .keyframeAnimator(initialValue: AnimationValues(),trigger: reactionCount) { content, value in
                        content
                            .rotationEffect(value.angle)
                            .scaleEffect(value.scale)
                            .offset(x: value.horizontalTranslation)
                            .offset(y: value.verticalTranslation)
                    } keyframes: { _ in
                        KeyframeTrack(\.scale){
                            SpringKeyframe(2.5, duration: 1.2, spring: .bouncy)
                        }
                        KeyframeTrack(\.verticalTranslation){
                            LinearKeyframe(200.0, duration: 0.2)
                        }
                        KeyframeTrack(\.horizontalTranslation){
                            LinearKeyframe(-300.0, duration: 0.2)
                        }
                    }
                Text("The Sky's The Limit")
                    .font(.custom("SpaceMono-Regular", size: 90))
                    .foregroundColor(.white)
                    .opacity(showText ? 1.0 : 0.0) // Fully opaque when showText is true, fully transparent otherwise
                    .animation(.easeInOut, value: showText)
            
              
            }
          
        }
    }
}

struct AnimationValues {
    var scale = 8.0
    var horizontalTranslation = 0.0
    var verticalTranslation = 0.0
    var angle  = Angle.zero
    var opacity = 0.0
}

#Preview {
    AnimationView()
}
