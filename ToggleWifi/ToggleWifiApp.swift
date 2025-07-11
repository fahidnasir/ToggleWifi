//
//  ToggleWifiApp.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import SwiftUI

@main
struct ToggleWifiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SettingsView(networkMonitor: NetworkMonitor(), wifiManager: WiFiManager())
        }
    }
}
