import SwiftUI

struct MainMenuView: View {
    @State private var isShowingTutorial = false   // <─ ADD THIS

    var body: some View {
        ZStack(alignment: .top) {

            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Let's start!")
                    .font(.custom("SpaceMono-Regular", size: 45))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Image("Meteor2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 25))

                Spacer()

                VStack(alignment: .leading, spacing: 40) {

                    NavigationLink("Draw The Stars", destination: EquationListView())
                    NavigationLink("My Galaxy", destination: ConstellationView())
//                    NavigationLink("Turtitoal", destination: TutorialLevelOneView())
                    // FIXED
                    NavigationLink(
                        "Tutorial",
                        destination: TutorialLevelOneView(isShowingTutorial: $isShowingTutorial)
                    )
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
