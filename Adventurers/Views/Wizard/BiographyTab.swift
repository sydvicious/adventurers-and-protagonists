import SwiftUI

struct BiographyTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        Text("Biography")
            .padding()
    }
}
