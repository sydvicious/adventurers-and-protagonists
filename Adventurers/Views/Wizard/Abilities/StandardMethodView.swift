import SwiftUI

struct StandardMethodView: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel
    @State private var standardText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Standard (4d6)")
                .font(.headline)
            TextField("Enter standard roll notes or result", text: $standardText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    StandardMethodView(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
