//
//  NetworkMonitor.swift
//
//
//  Created by Dmitry Mikhaylov on 20.03.2024.
//

import Combine
import Network

// MARK: - NetworkStatus

/// An enum to handle the network status
public enum NetworkStatus: String {
  case connected
  case disconnected
}

// MARK: - NetworkMonitor

public actor NetworkMonitor {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "Monitor")

  @Published @MainActor var status: NetworkStatus? = .none
  public static let shared = NetworkMonitor()
  private init() {
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else { return }

      // Monitor runs on a background thread so we need to publish
      // on the main thread
      Task { @MainActor in
        if path.status == .satisfied {
          self.status = .connected
          self.monitor.cancel()
        } else {
          self.status = .disconnected
        }
      }
    }
    monitor.start(queue: queue)
  }
}
