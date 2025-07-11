//
//  ContentView.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack {
            Image(systemName: "wifi")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(localizationManager.localizedString("main.title"))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
