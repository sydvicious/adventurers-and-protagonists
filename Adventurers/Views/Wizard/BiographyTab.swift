import SwiftUI

struct BiographyTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Please choose a name for your adventurer. You will be able to update it later.")
            TextField(
                "Unnamed",
                text: Binding(
                    get: { viewModel.proto.name },
                    set: {
                        viewModel.proto.name = $0
                        viewModel.notifyProtoChanged()
                    }
                )
            )
            .textFieldStyle(.roundedBorder)

            // Check mark icon below the text field
            let isValid = !viewModel.proto.name.isTrimmedStringEmpty()
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isValid ? .green : .gray)
                    .opacity(isValid ? 1.0 : 0.3)
                    .font(.system(size: 80, weight: .semibold))
                    .accessibilityLabel("Name \(isValid ? "is valid" : "is not valid")")
                Spacer()
            }
            .padding(.top, 24)
        }
        .padding()
    }
}

#Preview("Biography Tab") {
    BiographyTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}

#Preview("Biography Tab - Pendecar Mallathon") {
    let proto = Proto()
    proto.name = "Pendecar Mallathon"
    return BiographyTab(viewModel: NewAdventurerWizardViewModel(proto: proto))
}
