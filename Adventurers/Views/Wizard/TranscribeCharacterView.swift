import SwiftUI

struct TranscribeCharacterView: View {
    @State private var transcribeText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transcribe Character")
                .font(.headline)
            TextField("Enter details to transcribe", text: $transcribeText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

#Preview {
    TranscribeCharacterView()
}
