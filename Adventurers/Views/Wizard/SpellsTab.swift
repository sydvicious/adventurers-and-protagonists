import SwiftUI

struct SpellsTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Spells")
            .padding()
    }
}

#Preview("Spells Tab") {
    SpellsTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
