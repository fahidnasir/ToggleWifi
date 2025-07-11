//
//  ContentView.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("ToggleWiFi is running in the menu bar")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
