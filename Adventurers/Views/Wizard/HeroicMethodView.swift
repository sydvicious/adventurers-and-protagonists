import SwiftUI

struct HeroicMethodView: View {
    @State private var heroicText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heroic (2d6+6)")
                .font(.headline)
            TextField("Enter heroic roll notes or result", text: $heroicText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    HeroicMethodView()
}
