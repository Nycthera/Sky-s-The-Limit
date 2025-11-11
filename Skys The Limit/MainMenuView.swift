import SwiftUI

// MARK: - Welcome Screen
struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    Text("Welcome to")
                        .font(.custom("SpaceMono-Regular", size: 35))
                        .foregroundColor(.white)

                    Text("Sky's The Limit")
                        .font(.custom("SpaceMono-Regular", size: 50))
                        .foregroundColor(.white)

                    Spacer()

                    Image("AppIcon") // Your asset name
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 35))

                    Spacer()

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
            .navigationBarHidden(true)
        }
    }
}


// MARK: - Main Menu Screen
struct MainMenuView: View {
    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Let's start!")
                    .font(.custom("SpaceMono-Regular", size: 45))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Image("Comet") // Your asset name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 25))

                Spacer()

                VStack(alignment: .leading, spacing: 40) {
                    // Links to your other views
                    NavigationLink("Galaxy", destination: ConstellationView())
                    NavigationLink("Draw The Stars", destination: EquationListView())
                }
                .font(.custom("SpaceMono-Regular", size: 35))
                .foregroundColor(.white)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
