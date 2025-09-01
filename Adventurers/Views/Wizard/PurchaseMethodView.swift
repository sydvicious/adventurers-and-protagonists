import SwiftUI

struct PurchaseMethodView: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel
    @State private var purchaseText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Purchase")
                .font(.headline)
            TextField("Enter purchase points or details", text: $purchaseText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    PurchaseMethodView(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
