//
//  TestCoordinator.swift
//  Coordinator
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//
#if DEBUG
  import SwiftUI

  // MARK: - TestCoordinator

  final class TestCoordinator: NavigationModalCoordinator {
    enum Screen: ScreenProtocol {
      case screen1
      case screen2
      case screen3
    }

    enum Modal: ModalProtocol {
      case alert
      case settings
    }

    @MainActor
    func destination(for screen: Screen) -> some View {
      switch screen {
      case .screen1:
        Button("Go to Screen 2") {
          self.present(.screen2)
        }
      case .screen2:
        Button("Show Alert") {
          self.alert("Test", message: "This is a test alert")
        }
      case .screen3:
        Button("Show Settings") {
          self.present(.settings)
        }
      }
    }

    @MainActor
    func destination(for modal: Modal) -> some View {
      switch modal {
      case .alert:
        Text("Alert View")
      case .settings:
        Button("Close") {
          self.dismiss()
        }
      }
    }
  }

  // MARK: - TestView

  /// Example usage:
  struct TestView: View {
    @StateObject private var coordinator = TestCoordinator()

    var body: some View {
      if #available(iOS 16.0, *) {
        coordinator.view(for: .screen1)
      } else {
        // Fallback on earlier versions
      }
    }
  }

  #Preview {
    TestView()
  }

#endif
