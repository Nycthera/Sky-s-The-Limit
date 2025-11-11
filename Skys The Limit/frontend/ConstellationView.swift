import SwiftUI
import SwiftMath // <-- This was the missing import

struct ConstellationView: View {
    @EnvironmentObject var equationStore: EquationStore

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if equationStore.equations.isEmpty {
                        Text("No equations saved in your galaxy yet.")
                            .font(.custom("SpaceMono-Regular", size: 22))
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        ForEach(equationStore.equations, id: \.self) { equation in
                            MathView(equation: equation, textAlignment: .left, fontSize: 30)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Galaxy")
            .onAppear {
                equationStore.fetchEquations()
            }
        }
    }
}
