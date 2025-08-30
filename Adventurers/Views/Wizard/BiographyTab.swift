import SwiftUI

struct BiographyTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Biography")
            .padding()
    }
}

#Preview("Biography Tab") {
    BiographyTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
