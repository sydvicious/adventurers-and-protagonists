import SwiftUI

struct TranscribeCharacterView: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel
    
    init(viewModel: NewAdventurerWizardViewModel) {
        self.viewModel = viewModel
        if viewModel.proto.abilities.count == 0 {
            self.viewModel.proto.abilities = Proto.baseAbilities()
        }
    }

    var body: some View {
        VStack {
            VStack {
                Text("Enter the scores from your character sheet. They will not be adjusted in the other screens.")
                    .padding()
                
                Grid {
                    ForEach(0..<6) { index in
                        AbilitiesChooserEditScoreRow(
                            name: self.viewModel.proto.abilities[index].label,
                            score: $viewModel.proto.abilities[index].score)
                    }
                }
                .onAppear {
                    self.viewModel.notifyProtoChanged()
                }

                // Placeholder content
                Text("This feature is coming soon!")
                    .padding()
            }
        }
    }
}

#Preview {
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()

    return TranscribeCharacterView(viewModel: NewAdventurerWizardViewModel(proto: proto))
}
