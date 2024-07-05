//
//  WelcomeScreen.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var welcomeScreenShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to the Gallery of Adventurers and Other Creatures.").multilineTextAlignment(.center)
            Spacer()
            
            Button(action: {
                withAnimation() {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "WelcomeScreenShown")
                    welcomeScreenShowing = false
                }
            }) {
                Text("Let's go!")
            }
            Spacer()
            Text("Copyright ©2023-2024 Syd Polk").multilineTextAlignment(.center)
        }
    }
}

#Preview {
    @State var welcomeScreenShowing = true

    return WelcomeScreen(welcomeScreenShowing: $welcomeScreenShowing)
}
