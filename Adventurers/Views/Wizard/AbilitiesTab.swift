import SwiftUI

enum AbilityGenerationMethod: String, CaseIterable, Identifiable {
    case unspecified
    case transcribeCharacter
    case standard4d6
    case classic3d6
    case heroic2d6Plus6
    case dicePool
    case purchase

    var id: Self { self }

    var title: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .transcribeCharacter: return "Transcribe Character"
        case .standard4d6: return "Standard (4d6)"
        case .classic3d6: return "Classic (3d6)"
        case .heroic2d6Plus6: return "Heroic (2d6+6)"
        case .dicePool: return "Dice Pool"
        case .purchase: return "Purchase"
        }
    }

    // Use this to show only user-selectable options (exclude "Unspecified")
    static var displayCases: [AbilityGenerationMethod] {
        allCases.filter { $0 != .unspecified }
    }
}

struct AbilitiesTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        // Always show the chooser; it will present the selected method in a sheet.
        UnspecifiedAbilitiesView(viewModel: viewModel)
            .padding()
    }
}

#Preview("Abilities Tab") {
    AbilitiesTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}
