//
//  NetworkMonitor.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/6/24.
//

import Foundation
import Network

final class NetworkMonitor {
    
    private let queue = DispatchQueue.global()
    private let monitor = NWPathMonitor()
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    // 연결 타입
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    // Network Monitoring 시작
    func startMonitoring(completionHandler: @escaping (Bool) -> Void) {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            isConnected = path.status == .satisfied
            getConnectionType(path)
            
            DispatchQueue.main.async {
                completionHandler(self.isConnected)
            }
        }
    }
    
    // Network Monitoring 종료
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // Network 연결 타입가져오기.
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
