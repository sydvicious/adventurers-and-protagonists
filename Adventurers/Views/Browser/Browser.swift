//
//  Browser.swift
//  Adventurers
//
//  Created by Syd Polk on 6/11/25.
//

import SwiftData
import SwiftUI

struct Browser: View {
    @Query var adventurers: [Adventurer]

    @State private var selection: Adventurer?

    // Sheets
    @State private var welcomeScreenShowing: Bool = false
    @State private var wizardShowing: Bool = false

    var body: some View {
        ZStack {
            BrowserSplitView(selection: $selection,
                             welcomeScreenShowing: $welcomeScreenShowing,
                             wizardShowing: $wizardShowing)
        }
        .onAppear(perform: {
            let defaults = UserDefaults.standard
            welcomeScreenShowing = !defaults.bool(forKey: "WelcomeScreenShown")
            if self.adventurers.count == 0 {
                welcomeScreenShowing = true
            }
        })
        .sheet(isPresented: $welcomeScreenShowing, content:{
            WelcomeScreen(welcomeScreenShowing: $welcomeScreenShowing)
        })
        #if os(iOS)
        .fullScreenCover(isPresented: $wizardShowing) {
            ZStack {
                Color.white.ignoresSafeArea()
                let wizardViewModel = WizardViewModel(proto: Proto(from: selection))
                AdventurerWizard(wizardShowing: $wizardShowing)
                    .environmentObject(wizardViewModel)
            }
        }
        #endif
    }
}

#Preview {
    Browser()
}
