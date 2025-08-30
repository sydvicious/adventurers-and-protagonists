import SwiftUI

struct AbilityMethodSheetContainer<Content: View>: View {
    let viewModel: NewAdventurerWizardViewModel
    let onCancel: () -> Void
    let onDone: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.dismiss) private var dismiss

    private var isDoneEnabled: Bool {
        Proto.abilitiesReady(abilities: viewModel.proto.abilities)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Embedded method-specific content
            ScrollView {
                content
                    .padding()
            }

            Divider()

            // Action bar with Cancel / Done
            HStack {
                Button("Cancel") {
                    onCancel()
                    // Also dismiss if sheet is managed by environment
                    dismiss()
                }
                Button("Done") {
                    onDone()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isDoneEnabled)
            }
            .padding()
        }
        .frame(minWidth: 320, minHeight: 240)
    }
}

#Preview("Ability Method Sheet Container") {
    let vm = NewAdventurerWizardViewModel(proto: Proto())
    AbilityMethodSheetContainer(
        viewModel: vm,
        onCancel: {},
        onDone: {}
    ) {
        StandardMethodView()
    }
}
