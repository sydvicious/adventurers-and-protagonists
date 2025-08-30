import SwiftUI

struct UnspecifiedAbilitiesView: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel
    @State private var showingMethodSheet = false

    @ViewBuilder
    private func methodContent(for method: AbilityGenerationMethod) -> some View {
        switch method {
        case .unspecified:
            EmptyView()
        case .transcribeCharacter:
            TranscribeCharacterView()
        case .standard4d6:
            StandardMethodView()
        case .classic3d6:
            ClassicMethodView()
        case .heroic2d6Plus6:
            HeroicMethodView()
        case .dicePool:
            DicePoolMethodView()
        case .purchase:
            PurchaseMethodView()
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Choose the method for generating your abilities.")
                .font(.headline)

            // Always show all choices; tapping sets the method and presents the sheet.
            VStack(alignment: .center, spacing: 8) {
                ForEach(AbilityGenerationMethod.displayCases) { method in
                    Button(method.title) {
                        viewModel.abilitiesGeneratedMethod = method
                        showingMethodSheet = true
                    }
                }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .sheet(isPresented: $showingMethodSheet) {
            AbilityMethodSheetContainer(
                viewModel: viewModel,
                onCancel: { showingMethodSheet = false },
                onDone: { showingMethodSheet = false }
            ) {
                methodContent(for: viewModel.abilitiesGeneratedMethod)
            }
        }
    }
}

#Preview("Unspecified Abilities") {
    UnspecifiedAbilitiesView(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
