//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct AdventurerView: View {
    @Observable var selection: Adventurer?
    
    var body: some View {
        if let selection {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack {
                        Text(selection.name)
                            .padding()
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                    .frame(height: geometry.size.height)
                }
            }
        } else {
            Text("Please select a character from the list or add a new character.")
        }
    }
}

#Preview {
    return MainActor.assumeIsolated {
        AdventurerView(selection: .preview)
            .modelContainer(previewContainer)
    }
}
