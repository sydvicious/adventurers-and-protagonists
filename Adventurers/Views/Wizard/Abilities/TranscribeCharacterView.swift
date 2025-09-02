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
                
                Grid(horizontalSpacing: 6, verticalSpacing: 4) {
                    ForEach(0..<6) { index in
                        AbilitiesChooserEditScoreRow(
                            name: self.viewModel.proto.abilities[index].label,
                            score: $viewModel.proto.abilities[index].score)
                    }
                }
                #if os(macos)
                // Make the Grid visually smaller on macOS
                .font(.system(size: 11))              // smaller base font than .body
                .controlSize(.small)                  // smaller controls (TextField, Stepper)
                .frame(maxWidth: 320, alignment: .leading) // constrain width as desired
                // If you still want it even smaller, you can add a light scale:
                // .scaleEffect(0.95) // optional; note it scales hit targets
                #endif
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
