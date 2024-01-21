//
//  WizardPanel.swift
//  Adventurers
//
//  Created by Syd Polk on 1/14/24.
//

import SwiftUI

protocol WizardPanelProtocol {
    var isReady: Bool { get set }
    var isNewCharacter: Bool { get set }

    var proto: Proto { get set }
}

struct WizardPanel<Content: View>: View {
    @Binding var isReady: Bool
    @Binding var isNewCharacter: Bool
    @Binding var proto: Proto

    @ViewBuilder var content: Content

    var body: some View {
        GridRow {
            content
            Button(action: {
                
            }, label: {
                Image(systemName: "pencil")
                    .font(.caption)
                    .imageScale(.large)
            })
            ValidField(valid: isReady)
        }
        .padding([.all], 2)
    }
}

#Preview {
    struct TestView: View {
        @Binding var isReady: Bool
        @Binding var isNewCharacter: Bool
        @Binding var proto: Proto

        var body: some View {
            VStack {
                Text("foo")
                Text("bar")
            }
            .frame(maxWidth: .infinity)
        }
    }

    @State var isReady: Bool = false
    @State var isNewCharacter: Bool = true
    @State var proto: Proto = Proto.dummyProtoData()

    return Grid {
        WizardPanel(isReady: $isReady, isNewCharacter: $isNewCharacter, proto: $proto) {
            TestView(isReady: $isReady, isNewCharacter: $isNewCharacter, proto: $proto)
        }
    }
    .border(Color.red)
}

#Preview {
    struct TestView: View {
        @Binding var isReady: Bool
        @Binding var isNewCharacter: Bool
        @Binding var proto: Proto

        var body: some View {
            VStack {
                Text("\(proto.name)")
            }
            .frame(maxWidth: .infinity)
        }
    }

    @State var isReady: Bool = true
    @State var isNewCharacter: Bool = false
    @State var proto: Proto = Proto.dummyProtoData()
    proto.name = "Pendecar"

    return Grid {
        WizardPanel(isReady: $isReady, isNewCharacter: $isNewCharacter, proto: $proto) {
            TestView(isReady: $isReady, isNewCharacter: $isNewCharacter, proto: $proto)
        }
    }
    .border(Color.red)
}
