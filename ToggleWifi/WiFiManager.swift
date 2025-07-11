//
//  WiFiManager.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import Foundation

class WiFiManager: ObservableObject {
    private var wifiInterface: String?
    
    init() {
        detectWiFiInterface()
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
    
    func isWiFiEnabled() -> Bool {
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
    
    func setWiFiEnabled(_ enabled: Bool) {
        guard let interface = wifiInterface else { return }
        
        let task = Process()
        task.launchPath = "/usr/sbin/networksetup"
        task.arguments = ["-setairportpower", interface, enabled ? "on" : "off"]
        task.launch()
        task.waitUntilExit()
    }
}
