//
//  CharacterView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct CharacterView: View {
    @Observable var selection: Adventurer?
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    return MainActor.assumeIsolated {
        CharacterView(selection: .preview)
            .modelContainer(previewContainer)
    }
}
