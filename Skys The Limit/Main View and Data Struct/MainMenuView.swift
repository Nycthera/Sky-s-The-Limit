import SwiftUI

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

                Image("Meteor")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 25))

                Spacer()

                VStack(alignment: .leading, spacing: 40) {
                    // This is now the main puzzle game.
                    NavigationLink("Draw The Stars", destination: EquationListView())
                    
                    // This can link to a list of saved creations.
                    NavigationLink("My Galaxy", destination: ConstellationView())
                    //NavigationLink("Tutorial", destination: TutorialLevelOneView())
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
