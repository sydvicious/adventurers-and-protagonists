import SwiftUI

struct AbilitiesTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Abilities")
            .padding()
    }
}

#Preview("Abilities Tab") {
    AbilitiesTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
