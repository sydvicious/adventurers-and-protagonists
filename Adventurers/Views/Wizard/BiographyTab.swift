import SwiftUI

struct BiographyTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel
    @State private var tempName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Please choose a name for your adventurer. You will be able to update it later.")
            TextField("Unnamed", text: $tempName)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .onAppear {
            tempName = viewModel.proto.name
        }
    }
}

#Preview("Biography Tab") {
    BiographyTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
