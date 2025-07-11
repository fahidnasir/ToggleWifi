//
//  NetworkMonitor.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/11/25.
//

import Foundation
import Network

protocol NetworkMonitorDelegate: AnyObject {
    func ethernetStatusChanged(isConnected: Bool)
}

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    weak var delegate: NetworkMonitorDelegate?
    
    @Published var isEthernetConnected = false
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let ethernetConnected = path.availableInterfaces.contains { interface in
                interface.type == .wiredEthernet && path.usesInterfaceType(.wiredEthernet)
            }
            
            DispatchQueue.main.async {
                if ethernetConnected != self?.isEthernetConnected {
                    self?.isEthernetConnected = ethernetConnected
                    self?.delegate?.ethernetStatusChanged(isConnected: ethernetConnected)
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    func isEthernetCurrentlyConnected() -> Bool {
        return isEthernetConnected
    }
}
