//
//  WiFiManager.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import Foundation

class WiFiManager: ObservableObject {
    private var wifiInterface: String?
    @Published var isWiFiCurrentlyEnabled = false
    
    init() {
        detectWiFiInterface()
        updateWiFiStatus()
    }
    
    private func detectWiFiInterface() {
        let task = Process()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-listallhardwareports"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        let lines = output.components(separatedBy: .newlines)
        var foundWiFi = false
        
        for line in lines {
            if line.contains("Wi-Fi") || line.contains("AirPort") {
                foundWiFi = true
            } else if foundWiFi && line.contains("Device:") {
                wifiInterface = line.replacingOccurrences(of: "Device: ", with: "").trimmingCharacters(in: .whitespaces)
                break
            }
        }
        
        // Fallback to common interface names
        if wifiInterface == nil {
            wifiInterface = "en0"
        }
    }
    
    private func updateWiFiStatus() {
        DispatchQueue.main.async {
            self.isWiFiCurrentlyEnabled = self.checkWiFiEnabled()
        }
    }
    
    private func checkWiFiEnabled() -> Bool {
        guard let interface = wifiInterface else { return false }
        
        let task = Process()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-getairportpower", interface]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return output.contains("On")
    }
    
    func isWiFiEnabled() -> Bool {
        let enabled = checkWiFiEnabled()
        DispatchQueue.main.async {
            self.isWiFiCurrentlyEnabled = enabled
        }
        return enabled
    }
    
    func setWiFiEnabled(_ enabled: Bool) {
        guard let interface = wifiInterface else { return }
        
        let task = Process()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-setairportpower", interface, enabled ? "on" : "off"]
        task.launch()
        task.waitUntilExit()
        
        // Update the published property after changing the state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateWiFiStatus()
        }
    }
}
