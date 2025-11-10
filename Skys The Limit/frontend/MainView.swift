//
//  MainView.swift
//  Skys The Limit
//
//  Created by Nhavin Thirukkumaran on 7/11/25.
//
import SwiftUI



struct MainMenuView: View {
    var body: some View {
        // ZStack for the background
        ZStack {
            Image("{PlaceHolder}")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // VStack for the content
            VStack(spacing: 30) {
                
                Text("Let's start!")
                    .font(.custom("{PlaceHolder}", size: 50)) // <-- Replace with your font's name
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Image("{PlaceHolder}")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                
                Spacer()
                
                // The three menu options as buttons
                VStack(alignment: .leading, spacing: 40) {
                    Button(action: {
                        print("Galaxy tapped!")
                        // Navigate to your Galaxy view here
                    }) {
                        Text("Galaxy")
                    }
                    
                    Button(action: {
                        print("Draw The Stars tapped!")
                        // Navigate to your drawing view here
                    }) {
                        Text("Draw The Stars")
                    }
                    
                    Button(action: {
                        print("Create tapped!")
                        // Navigate to your equation editor here
                    }) {
                        Text("Create")
                    }
                }
                .font(.custom("{PlaceHolder}", size: 40)) // <-- Replace with your font's name
                .foregroundColor(.white)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true) // Hides the back button
    }
}




struct WelcomeView: View {
    var body: some View {
        // NavigationView is the root of our navigation stack.
        // It allows us to move from this screen to the MainMenuView.
        NavigationView {
            // ZStack lets us place the background behind all other content.
            ZStack {
                // The starry background
                Image("{PlaceHolder}")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                // VStack arranges the content vertically.
                VStack(spacing: 20) {
                    Spacer()
                    
                    // The welcome text
                    Text("Welcome to")
                        .font(.custom("{PlaceHolder}", size: 40)) // <-- Replace with your font's name
                        .foregroundColor(.white)
                    
                    Text("Sky's The Limit")
                        .font(.custom("{PlaceHolder}", size: 60)) // <-- Replace with your font's name
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // The comet image from your assets
                    Image("{PlaceHolder}")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                    Spacer()
                    
                    // The navigation button that takes the user to the main menu.
                    // It's a NavigationLink that is styled to look like a custom button.
                    NavigationLink(destination: MainMenuView()) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hides the default top navigation bar
        }
    }
}


