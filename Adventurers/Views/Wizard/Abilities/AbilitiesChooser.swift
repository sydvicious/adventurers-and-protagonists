//
//  AbilitiesChooser.swift
//  Adventurers
//
//  Created by Syd Polk on 6/21/24.
//

import SwiftUI

struct AbilitiesChooser: View, WizardProtocol {
    @Binding @MainActor var isShowing: Bool
    @Binding @MainActor var isReady: Bool
    @Binding @MainActor var proto: Proto

    @ObservedObject var viewModel: AbilitiesChooserViewModel = AbilitiesChooserViewModel()

    var doneDisabled: Bool
    var creatingNewCharacter: Bool

    init(isShowing: Binding<Bool>, 
         isReady: Binding<Bool>,
         proto: Binding<Proto>,
         creatingNewCharacter: Bool,
         chooserType: AbilityChooserTypes = .intro) {
        self._isShowing = isShowing
        self._isReady = isReady
        self._proto = proto
        self.viewModel = AbilitiesChooserViewModel(chooserType: chooserType, proto: proto.wrappedValue)
        self.creatingNewCharacter = creatingNewCharacter
        self.doneDisabled = true
    }

    var body: some View {
        ScrollView {
            VStack {
                switch viewModel.chooserType {
                case .intro:
                    Intro()
                case .transcribe:
                    Transcribe()
                case .roll4d6Best3:
                    Roll4d6Best3().disabled(true)
                case .points:
                    Points().disabled(true)
                }
            }
            .navigationTitle(creatingNewCharacter ? "Set your adventurer's abilities" : "Edit your anventurer's abilities")
        }
        Spacer()
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(doneDisabled)
        }
    }

    mutating func checkDoneDisabled() {
        self.doneDisabled = viewModel.proto.abilitiesReady()
    }

    func cancel() {
        self.isShowing = false
    }

    func done() {
        self.proto = Proto.protoFromProto(oldProto: viewModel.proto)
        self.isShowing = false
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()
    proto.name = "Pendecar"

    return AbilitiesChooser(isShowing: $wizardShowing, isReady: $isReady, proto: $proto, creatingNewCharacter: true, chooserType: .intro)
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()
    proto.name = "Pendecar"

    return AbilitiesChooser(isShowing: $wizardShowing, isReady: $isReady, proto: $proto, creatingNewCharacter: false)
}
