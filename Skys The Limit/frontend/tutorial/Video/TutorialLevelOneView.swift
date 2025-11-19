//////
//////  TutorialLevelOneView.swift
////  Skys The Limit
////
////  Created by Chris  on 17/11/25.
////

import AVKit
import SwiftUI
struct TutorialLevelOneView: View {
    @Binding var isShowingTutorial : Bool
    
    private let VideoFiles = ["Recording-1", "Recording-2", "Recording-3", "HIIII WO AI NI"]
    
    var body : some View {
        VStack{
            TabView {
                ForEach(VideoFiles, id: \.self) { fileName in
                    if let url = Bundle.main.url(forResource: fileName, withExtension: "mov") {
                        VideoPlayer(player: AVPlayer(url: url))
                            .padding()
                    } else {
                        Text("Video \(fileName) not found")
                            .foregroundColor(.red)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .tabViewStyle(.page(indexDisplayMode: .always))
            Button("Done") {
                isShowingTutorial = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding()
        }
    }
    
    
}
