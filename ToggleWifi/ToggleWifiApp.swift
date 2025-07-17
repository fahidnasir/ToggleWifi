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
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    var body: some Scene {
        WindowGroup {
            SettingsView(networkMonitor: NetworkMonitor(), wifiManager: WiFiManager())
        }
    }
    
    init() {
        if UserDefaults.standard.object(forKey: "notificationsEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
        }
    }
}
