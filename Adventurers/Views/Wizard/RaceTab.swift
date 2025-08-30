import SwiftUI

struct RaceTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Race")
            .padding()
    }
}

#Preview("Race Tab") {
    RaceTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
