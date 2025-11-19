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
            //            Image("Space")
            //                .resizable()
            //                .aspectRatio(contentMode: .fill)
            //                .edgesIgnoringSafeArea(.all)
            
            
            GalaxyBackground()
                .ignoresSafeArea()
                .onAppear(){
                    reactionCount += 1
                    showText = true
                }
            
            
            VStack {
                Spacer()
                Image("Meteor2")
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
    @State private var blobShift = false
    @State private var blobSwirl = false
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
            
            
            // swirling colour blobs in the center that gradually gets mixed together like it shifts but i kinda want a swirl like marbled cake
            ZStack {
                MarbledBlob(color: .purple, scale: 1.5, opacity: 0.7,
                            offsetX: blobShift ? -220 : 180,
                            offsetY: blobShift ? -120 : 140,
                            swirl: blobSwirl)
                
                MarbledBlob(color: .blue, scale: 1.7, opacity: 0.5,
                            offsetX: blobShift ? 250 : -200,
                            offsetY: blobShift ? 90 : -140,
                            swirl: blobSwirl)
                
                MarbledBlob(color: .pink, scale: 1.5, opacity: 0.3,
                            offsetX: blobShift ? -180 : 200,
                            offsetY: blobShift ? 200 : -160,
                            swirl: blobSwirl)
                
                MarbledBlob(color: .yellow, scale: 1.6, opacity: 0.35,
                            offsetX: blobShift ? 160 : -140,
                            offsetY: blobShift ? -200 : 140,
                            swirl: blobSwirl)
                
            }
            .blur(radius: 10)
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: blobShift)
            .animation(.linear(duration: 40).repeatForever(autoreverses: false), value: blobSwirl)
            
            
            
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
        .onAppear {
            blobShift = true      // blobs drift
            blobSwirl = true      // blobs rotate
        }
    }
}


//marble blob struct
struct MarbledBlob: View {
    var color: Color
    var scale: CGFloat
    var opacity: CGFloat
    var offsetX: CGFloat
    var offsetY: CGFloat
    var swirl: Bool
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(opacity),
                        color.opacity(opacity * 0.5),
                        color.opacity(opacity * 0.1)
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: 250
                )
            )
            .scaleEffect(scale)
            .offset(x: offsetX, y: offsetY)
            .rotationEffect(.degrees(swirl ? 360 : 0))
            .animation(.linear(duration: Double.random(in: 18...30)).repeatForever(autoreverses: false),
                       value: swirl)
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
