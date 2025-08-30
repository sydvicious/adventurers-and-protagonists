import SwiftUI

struct ClassicMethodView: View {
    @State private var classicText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Classic (3d6)")
                .font(.headline)
            TextField("Enter classic roll notes or result", text: $classicText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    ClassicMethodView()
}
