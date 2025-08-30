import SwiftUI

struct EquipmentTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Equipment")
            .padding()
    }
}

#Preview("Equipment Tab") {
    EquipmentTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
