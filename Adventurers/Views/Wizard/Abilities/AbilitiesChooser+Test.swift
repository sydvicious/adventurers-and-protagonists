//
//  AbilitiesChooser+Test.swift
//  Adventurers
//
//  Created by Syd Polk on 6/23/24.
//

import Foundation
import SwiftUI

@MainActor
extension AbilitiesChooser {
    @ViewBuilder func Test() -> some View {
        let abilities = Proto.abilities(from: viewModel.abilities)
        AbilitiesView(viewModel: AbilitiesViewModel(abilities: abilities))
    }
}
