import SwiftUI

struct UnspecifiedAbilitiesView: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    @ViewBuilder
    private func methodContent(for method: AbilityGenerationMethod) -> some View {
        switch method {
        case .unspecified:
            EmptyView()
        case .transcribeCharacter:
            TranscribeCharacterView(viewModel: viewModel)
        case .standard4d6:
            StandardMethodView(viewModel: viewModel)
        case .classic3d6:
            ClassicMethodView(viewModel: viewModel)
        case .heroic2d6Plus6:
            HeroicMethodView(viewModel: viewModel)
        case .dicePool:
            DicePoolMethodView(viewModel: viewModel)
        case .purchase:
            PurchaseMethodView(viewModel: viewModel)
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Choose the method for generating your abilities.")
                .font(.headline)

            // Always show all choices; tapping navigates to the method's view.
            VStack(alignment: .center, spacing: 8) {
                ForEach(AbilityGenerationMethod.displayCases) { method in
                    NavigationLink(method.title) {
                        AbilityMethodContainer(
                            viewModel: viewModel,
                            onCancel: {},
                            onDone: {}
                        ) {
                            methodContent(for: method)
                        }
                        .onAppear {
                            viewModel.abilitiesGeneratedMethod = method
                        }
                    }
                }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview("Unspecified Abilities") {
    NavigationStack {
        UnspecifiedAbilitiesView(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
    }
}
