//
//  ValidField.swift
//  Adventurers
//
//  Created by Syd Polk on 7/28/23.
//

import SwiftUI

struct ValidField: View {
    @Binding var valid: Bool

    var body: some View {
        if valid {
            Image(systemName: "checkmark")
                .font(.caption)
                .imageScale(.large)
        } else {
            Image(systemName: "circle.slash")
                .font(.caption)
                .imageScale(.large)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    @State var isValid: Bool = false
    return ValidField(valid: $isValid)
}

#Preview {
    @State var isValid: Bool = true

    return ValidField(valid: $isValid)
}
