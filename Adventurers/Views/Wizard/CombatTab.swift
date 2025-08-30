import SwiftUI

struct CombatTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Combat")
            .padding()
    }
}

#Preview("Combat Tab") {
    CombatTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
