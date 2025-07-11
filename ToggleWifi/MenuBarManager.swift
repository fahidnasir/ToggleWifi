//
//  MenuBarManager.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import Cocoa
import SwiftUI
import UserNotifications

class MenuBarManager: NSObject, NetworkMonitorDelegate {
    private var statusItem: NSStatusItem?
    private var wifiManager: WiFiManager
    private var networkMonitor: NetworkMonitor
    private var settingsWindow: NSWindow?
    private let localizationManager = LocalizationManager.shared
    
    @AppStorage("autoWiFiEnabled") private var autoWiFiEnabled = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    init(wifiManager: WiFiManager, networkMonitor: NetworkMonitor) {
        self.wifiManager = wifiManager
        self.networkMonitor = networkMonitor
        super.init()
        
        // Listen for language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: Notification.Name("LanguageChanged"),
            object: nil
        )
    }
    
    @objc private func languageChanged() {
        setupMenu()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateIcon()
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupMenu()
    }
    
    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .leftMouseUp {
            toggleWiFiManually()
        } else if event.type == .rightMouseUp {
            return
        }
    }
    
    private func setupMenu() {
        statusItem?.menu = createMenu()
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        let autoToggleItem = NSMenuItem(
            title: localizationManager.localizedString("menu.autoWiFi"),
            action: #selector(toggleAutoWiFi),
            keyEquivalent: ""
        )
        autoToggleItem.target = self
        autoToggleItem.state = autoWiFiEnabled ? .on : .off
        menu.addItem(autoToggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(
            title: localizationManager.localizedString("menu.settings"),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        let aboutItem = NSMenuItem(
            title: localizationManager.localizedString("menu.about"),
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
            title: localizationManager.localizedString("menu.quit"),
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc private func toggleAutoWiFi() {
        autoWiFiEnabled.toggle()
        updateIcon()
        setupMenu()
    }
    
    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView(networkMonitor: networkMonitor, wifiManager: wifiManager)
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 350),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            settingsWindow?.title = localizationManager.localizedString("settings.title")
            settingsWindow?.contentViewController = hostingController
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false
            
            NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: settingsWindow,
                queue: nil
            ) { [weak self] _ in
                self?.settingsWindow = nil
            }
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = localizationManager.localizedString("about.title")
        alert.informativeText = "\(localizationManager.localizedString("about.version"))\n\(localizationManager.localizedString("about.description"))"
        alert.alertStyle = .informational
        alert.addButton(withTitle: localizationManager.localizedString("about.ok"))
        alert.runModal()
    }
    
    @objc private func quit() {
        NSApp.terminate(nil)
    }
    
    private func toggleWiFiManually() {
        let currentState = wifiManager.isWiFiEnabled()
        wifiManager.setWiFiEnabled(!currentState)
        updateIcon()
        
        let message = currentState ?
            localizationManager.localizedString("notification.wifiOff") :
            localizationManager.localizedString("notification.wifiOn")
        showNotification(title: "Wi-Fi Status", message: message)
    }
    
    private func updateIcon() {
        let wifiEnabled = wifiManager.isWiFiEnabled()
        let iconName: String
        
        if !autoWiFiEnabled {
            iconName = "wifi.exclamationmark"
        } else if wifiEnabled {
            iconName = "wifi"
        } else {
            iconName = "wifi.slash"
        }
        
        statusItem?.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
    }
    
    private func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - NetworkMonitorDelegate
    
    func ethernetStatusChanged(isConnected: Bool) {
        guard autoWiFiEnabled else { return }
        
        if isConnected {
            if wifiManager.isWiFiEnabled() {
                wifiManager.setWiFiEnabled(false)
                showNotification(
                    title: localizationManager.localizedString("notification.ethernetConnected"),
                    message: localizationManager.localizedString("notification.wifiOff")
                )
            }
        } else {
            if !wifiManager.isWiFiEnabled() {
                wifiManager.setWiFiEnabled(true)
                showNotification(
                    title: localizationManager.localizedString("notification.ethernetDisconnected"),
                    message: localizationManager.localizedString("notification.wifiOn")
                )
            }
        }
        
        updateIcon()
    }
}
