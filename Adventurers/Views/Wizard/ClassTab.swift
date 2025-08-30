import SwiftUI

struct ClassTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Class")
            .padding()
    }
}

#Preview("Class Tab") {
    ClassTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
