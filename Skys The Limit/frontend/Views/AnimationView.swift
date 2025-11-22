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
            GalaxyBackground()
                .ignoresSafeArea()
                .onAppear(){
                    reactionCount += 1
                    showText = true
                }
            
            
            VStack {
                Spacer()
                Image("Meteor")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .keyframeAnimator(initialValue: AnimationValues(),trigger: reactionCount) { content, value in
                        content
                            .rotationEffect(value.angle)
                            .scaleEffect(value.scale)
                            .offset(x: value.horizontalTranslation)
                            .offset(y: value.verticalTranslation)
                    } keyframes: { _ in
                        KeyframeTrack(\.scale){
                            SpringKeyframe(1.0, duration: 1.2, spring: .bouncy)
                        }
                        KeyframeTrack(\.verticalTranslation){
                            LinearKeyframe(200.0, duration: 0.2)
                        }
                        KeyframeTrack(\.horizontalTranslation){
                            LinearKeyframe(100.0, duration: 0.2)
                        }
                    }
                Spacer()
                
                Text("The Sky's The Limit")
                    .font(.custom("SpaceMono-Regular", size: 90))
                    .foregroundColor(.white)
                    .opacity(showText ? 1.0 : 0.0) // Fully opaque when showText is true, fully transparent otherwise
                    .animation(.easeInOut, value: showText)
                    .padding(110)
                
                Spacer()
            }
            
        }
    }
}

struct GalaxyBackground: View {
    @State private var starAnimate = false
    @State private var starDrift = false
    @State private var fogShift = false
    @State private var fieldSpin = false
    
    var body: some View {
        ZStack {
            
            
            // this is the dark fade outer rhim like you know the camera setting
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black,
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 900
            )
            .ignoresSafeArea()
            
            
            // the sparkly stars
            ZStack {
                ZStack {
                    ForEach(0..<120) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.4...1)))
                            .frame(width: CGFloat.random(in: 2...6))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .blur(radius: CGFloat.random(in: 2...6))
                            .opacity(starDrift ? Double.random(in: 0.2...1) : Double.random(in: 0.4...1))
                            .animation(
                                .easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true),
                                value: starDrift
                            )
                    }
                }
                .blendMode(.screen)
                
                //smal sharp stars
                
                ZStack {
                    ForEach(0..<200) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...1)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .offset(
                                x: starDrift ? CGFloat.random(in: -10...10) : 0,
                                y: starDrift ? CGFloat.random(in: -10...10) : 0
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true),
                                value: starDrift
                            )
                    }
                }
                .blendMode(.screen)
            }
            .ignoresSafeArea()
            .onAppear {
                starAnimate = true
                starDrift = true
                fogShift = true
                fieldSpin = true
            }
            .blendMode(.screen)
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
