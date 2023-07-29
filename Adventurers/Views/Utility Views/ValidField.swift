//
//  ValidField.swift
//  Adventurers
//
//  Created by Syd Polk on 7/28/23.
//

import SwiftUI

struct ValidField: View {
    var valid: Bool

    init(valid: Bool) {
        self.valid = valid
    }

    var body: some View {
        if valid {
            Image(systemName: "checkmark")
                .font(.caption)
                .imageScale(.medium)
        } else {
            Image(systemName: "circle.slash")
                .font(.caption)
                .imageScale(.medium)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    return ValidField(valid: false)
}

#Preview {
    return ValidField(valid: true)
}
