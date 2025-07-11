//
//  AppDelegate.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import Cocoa
import SwiftUI
import ServiceManagement
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager?
    var networkMonitor: NetworkMonitor?
    var wifiManager: WiFiManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and main window
        NSApp.setActivationPolicy(.accessory)
        
        // Request notification permissions
        requestNotificationPermissions()
        
        // Initialize managers
        wifiManager = WiFiManager()
        networkMonitor = NetworkMonitor()
        menuBarManager = MenuBarManager(wifiManager: wifiManager!, networkMonitor: networkMonitor!)
        
        // Setup network monitoring
        networkMonitor?.delegate = menuBarManager
        networkMonitor?.startMonitoring()
        
        // Setup menu bar
        menuBarManager?.setupMenuBar()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        networkMonitor?.stopMonitoring()
    }
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}
