//
//  SettingsView.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("autoWiFiEnabled") private var autoWiFiEnabled = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var wifiManager: WiFiManager
    
    init(networkMonitor: NetworkMonitor, wifiManager: WiFiManager) {
        self.networkMonitor = networkMonitor
        self.wifiManager = wifiManager
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ToggleWiFi Settings")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Enable Auto Wi-Fi Toggle", isOn: $autoWiFiEnabled)
                    .help("Automatically turn Wi-Fi off when Ethernet is connected")
                
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .help("Start ToggleWiFi when you log in")
                    .onChange(of: launchAtLogin) { oldValue, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Status")
                    .font(.headline)
                
                HStack {
                    Text("Ethernet:")
                    Text(networkMonitor.isEthernetConnected ? "Connected" : "Disconnected")
                        .foregroundColor(networkMonitor.isEthernetConnected ? .green : .red)
                }
                
                HStack {
                    Text("Wi-Fi:")
                    Text(wifiManager.isWiFiCurrentlyEnabled ? "On" : "Off")
                        .foregroundColor(wifiManager.isWiFiCurrentlyEnabled ? .green : .red)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 300)
        .onAppear {
            // Force refresh the WiFi status when the view appears
            _ = wifiManager.isWiFiEnabled()
        }
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }
}

#Preview {
    SettingsView(networkMonitor: NetworkMonitor(), wifiManager: WiFiManager())
}
