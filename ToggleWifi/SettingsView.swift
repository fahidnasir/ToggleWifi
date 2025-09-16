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
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var wifiManager: WiFiManager
    @StateObject private var localizationManager = LocalizationManager.shared
    
    private let availableLanguages = [
        ("en", "language.english"),
        ("de", "language.german"),
        ("zh-Hans", "language.chinese")
    ]
    
    init(networkMonitor: NetworkMonitor, wifiManager: WiFiManager) {
        self.networkMonitor = networkMonitor
        self.wifiManager = wifiManager
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(localizationManager.localizedString("settings.title"))
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle(localizationManager.localizedString("settings.autoWiFiToggle"), isOn: $autoWiFiEnabled)
                    .help(localizationManager.localizedString("settings.autoWiFiHelp"))
                
                Toggle(localizationManager.localizedString("settings.enableNotifications"), isOn: $notificationsEnabled)
                    .help(localizationManager.localizedString("settings.enableNotificationsHelp"))
                
                Toggle(localizationManager.localizedString("settings.launchAtLogin"), isOn: $launchAtLogin)
                    .help(localizationManager.localizedString("settings.launchAtLoginHelp"))
                    .onChange(of: launchAtLogin) { oldValue, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
                
                // Language Selection
                HStack {
                    Text(localizationManager.localizedString("settings.language"))
                        .frame(width: 100, alignment: .leading)
                    
                    Picker("", selection: $localizationManager.currentLanguage) {
                        ForEach(availableLanguages, id: \.0) { languageCode, localizedKey in
                            Text(localizationManager.localizedString(localizedKey))
                                .tag(languageCode)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                    .onChange(of: localizationManager.currentLanguage) { oldValue, newValue in
                        localizationManager.setLanguage(newValue)
                        // Notify other parts of the app about language change
                        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
                    }
                    
                    Spacer()
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.localizedString("settings.status"))
                    .font(.headline)
                
                HStack {
                    Text(localizationManager.localizedString("settings.ethernet"))
                    Text(networkMonitor.isEthernetConnected ?
                         localizationManager.localizedString("settings.connected") :
                         localizationManager.localizedString("settings.disconnected"))
                        .foregroundColor(networkMonitor.isEthernetConnected ? .green : .red)
                }
                
                HStack {
                    Text(localizationManager.localizedString("settings.wifi"))
                    Text(wifiManager.isWiFiCurrentlyEnabled ?
                         localizationManager.localizedString("settings.on") :
                         localizationManager.localizedString("settings.off"))
                        .foregroundColor(wifiManager.isWiFiCurrentlyEnabled ? .green : .red)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 450, height: 350)
        .onAppear {
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
