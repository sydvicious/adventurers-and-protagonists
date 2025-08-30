import SwiftUI

struct SkillsTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Skills")
            .padding()
    }
}

#Preview("Skills Tab") {
    SkillsTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
