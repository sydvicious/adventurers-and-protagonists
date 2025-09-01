import SwiftUI

struct TranscribeCharacterView: View {
    var body: some View {
        VStack {
            Text("Transcribe Character")
                .font(.title2)
                .padding()
            
            Text("Enter your character's abilities manually.")
                .foregroundStyle(.secondary)
                .padding()
            
            // Placeholder content
            Text("This feature is coming soon!")
                .padding()
        }
    }
}

#Preview {
    TranscribeCharacterView()
}