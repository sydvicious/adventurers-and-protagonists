import SwiftUI

struct DicePoolMethodView: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel
    @State private var dicePoolText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dice Pool")
                .font(.headline)
            TextField("Enter dice pool configuration", text: $dicePoolText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    DicePoolMethodView(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
