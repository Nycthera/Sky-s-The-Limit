////
////  TutorialLevelOneView.swift
////  Skys The Limit
////
////  Created by Chris  on 17/11/25.
////
//
//import AVKit
//import SwiftUI
//struct TutorialLevelOneView: View {
//    @Binding var isShowingTutorial : Bool
//    
//    private let VideoFiles = []
//    
//    var body : some View {
//        VStack{
//            TabView {
//                ForEach(VideoFiles, id: \.self) { fileName in
//                    VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: {fileName}, withExtension: "mp4")!))
//                    VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: {fileName}, withExtension: "mp4")!))
//                    VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: {fileName}, withExtension: "mp4")!))
//                        .padding()
//                }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .always))
//        }
//    }
////    Button("Done"){
////        isShowingTutorial = false
////    }
////    .fontWeight(.semibold)
////    .padding()
////    .frame(maxWidth: .infinity)
////    .background(Color.blue)
////    .foregroundColor(.white)
////    .cornerRadius(15)
////    .padding()
//    
//}
