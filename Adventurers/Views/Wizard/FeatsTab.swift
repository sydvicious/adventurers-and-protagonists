import SwiftUI

struct FeatsTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Feats")
            .padding()
    }
}

#Preview("Feats Tab") {
    FeatsTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
