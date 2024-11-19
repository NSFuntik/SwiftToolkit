//
//  ModalCoordinator.swift
//  ModalCoordinator
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//

import Foundation
import SwiftUI

// MARK: - ModalStyle

/// Defines the presentation style for modal flows.
///
/// Use this enum to specify how modal content should be displayed in the UI.
public enum ModalStyle {
  /// Presents content in a sheet that partially covers the screen
  case sheet

  /// Presents content as a full-screen cover
  case cover

  /// Presents content as an overlay on top of current navigation
  ///
  /// - Note: This style doesn't interfere with native navigation or modal presentation flow
  case overlay

  #if os(macOS)
    public static var fullScreen: ModalStyle { .sheet }
  #else
    public static var fullScreen: ModalStyle { .cover }
  #endif
}

// MARK: - ModalProtocol

/// Protocol for defining modal navigation flows.
///
/// Implement this protocol to define the different modal presentations available in your app.
///
/// Example implementation:
/// ```swift
/// enum ModalFlow: ModalProtocol {
///     case settings
///     case profile(User)
///     case help
///
///     var style: ModalStyle {
///         switch self {
///         case .settings: return .sheet
///         case .profile: return .cover
///         case .help: return .overlay
///         }
///     }
/// }
/// ```
public protocol ModalProtocol: Hashable, Identifiable {
  /// The presentation style for this modal flow
  var style: ModalStyle { get }
}

public extension ModalProtocol {
  /// Default implementation returns .sheet style
  var style: ModalStyle { .sheet }

  /// Default implementation uses hash value as identifier
  var id: Int { hashValue }
}

public extension ModalProtocol {
  /// Returns the coordinator associated with this modal flow, if any
  var coordinator: (any Coordinator)? {
    for child in Mirror(reflecting: self).children {
      if let value = child.value as? (any Coordinator) {
        return value
      }
    }
    return nil
  }
}

// MARK: - ModalCoordinator

/// Protocol for coordinators that manage modal presentations.
///
/// Implement this protocol to create a coordinator that can present modal views
/// and manage modal navigation flows.
///
/// Example implementation:
/// ```swift
/// final class AppModalCoordinator: ModalCoordinator {
///     enum Modal: ModalProtocol {
///         case settings
///         case profile
///     }
///
///     func destination(for modal: Modal) -> some View {
///         switch modal {
///         case .settings: SettingsView()
///         case .profile: ProfileView()
///         }
///     }
/// }
/// ```
public protocol ModalCoordinator: Coordinator {
  /// The type defining possible modal flows
  associatedtype Modal: ModalProtocol

  /// The type of view returned for modal presentations
  associatedtype ModalView: View

  /// Returns the view to be presented for a given modal flow
  ///
  /// - Parameter modal: The modal flow to create a view for
  /// - Returns: The view to be presented
  @ViewBuilder func destination(for modal: Modal) -> ModalView
}

// MARK: - PresentationResolve

/// Resolution strategies for handling multiple modal presentations
/// Defines how to handle presenting a new modal when one is already presented.
public enum PresentationResolve {
  /// Present the new modal over the currently presented one
  case overAll

  /// Dismiss the current modal and present the new one
  case replaceCurrent
}

public extension ModalCoordinator {
  /// Present a flow modally over the current navigation.
  ///
  /// - Parameters:
  ///   - modalFlow: The modal flow to present
  ///   - resolve: The resolution strategy for handling existing presentations
  @MainActor
  func present(
    _ modalFlow: Modal,
    resolve: PresentationResolve = .overAll
  ) {
    present(
      .init(
        modalFlow: modalFlow,
        destination: { [unowned self] in
          AnyView(self.destination(for: modalFlow))
        }
      ),
      resolve: resolve
    )
  }
}

// MARK: - ModalPresentation

/// Represents a modal presentation with its associated coordinator.
@MainActor
public struct ModalPresentation {
  private final class PlaceholderCoordinator: Coordinator {
    typealias Screen = Never
    typealias ScreenView = Never
  }

  /// The modal flow being presented
  public let modalFlow: any ModalProtocol

  /// The coordinator managing this presentation
  let coordinator: any Coordinator

  /// Closure that returns the view to be presented
  let destination: () -> AnyView

  /// Creates a new modal presentation.
  ///
  /// - Parameters:
  ///   - modalFlow: The modal flow to present
  ///   - destination: Closure returning the view to present
  public init(
    modalFlow: any ModalProtocol,
    destination: @escaping () -> AnyView
  ) {
    self.modalFlow = modalFlow

    if let coordinator = modalFlow.coordinator {
      self.destination = destination
      self.coordinator = coordinator
    } else {
      let coordinator = PlaceholderCoordinator()
      self.destination = { [weak coordinator] in
        guard let coordinator else { return AnyView(EmptyView()) }
        return AnyView(destination().withModal(coordinator))
      }
      self.coordinator = coordinator
    }
  }
}

// MARK: - ModalModifer

/// ViewModifier that adds modal presentation capability to a view.
@MainActor
private struct ModalModifer: ViewModifier {
  @ObservedObject var state: NavigationState

  /// Creates a binding for modal presentation state.
  ///
  /// - Parameter style: The modal style to create a binding for
  /// - Returns: A binding that manages the presentation state
  private func isPresentedBinding(_ style: ModalStyle) -> Binding<Bool> {
    .init { [weak state] in
      state?.modalPresented?.modalFlow.style == style
    } set: { [weak state] _ in
      if let presented = state?.modalPresented,
         let overlayPresented = presented.coordinator.state.modalPresented,
         overlayPresented.modalFlow.style == .overlay
      {
        presented.coordinator.state.modalPresented = nil
      } else {
        state?.modalPresented = nil
      }
    }
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if let presented = state.modalPresented,
           presented.modalFlow.style == .overlay
        {
          presented.destination()
            .coordinateSpace(name: CoordinateSpace.modal)
        }
      }
      .sheet(isPresented: isPresentedBinding(.sheet)) {
        state.modalPresented?.destination()
          .coordinateSpace(name: CoordinateSpace.modal)
      }
    #if os(iOS)
      .fullScreenCover(isPresented: isPresentedBinding(.cover)) {
        state.modalPresented?.destination()
          .coordinateSpace(name: CoordinateSpace.modal)
      }
    #endif
      .alert(
        state.alerts.last?.title ?? "",
        isPresented: Binding(
          get: { state.alerts.last != nil },
          set: { _ in
            if !state.alerts.isEmpty {
              state.alerts.removeLast()
            }
          }
        ),
        actions: state.alerts.last?.actions ?? { AnyView(EmptyView()) },
        message: state.alerts.last?.message ?? { AnyView(EmptyView()) }
      )
  }
}

// MARK: - Navigation Modal Coordinator

/// A type alias for a coordinator that combining modal and navigation coordination capabilities
public typealias NavigationModalCoordinator = ModalCoordinator & NavigationCoordinator

// MARK: - NavigationState.Alert

public extension NavigationState {
  /// Represents an alert that can be presented by a coordinator.
  struct Alert {
    let title: String
    let actions: () -> AnyView
    let message: () -> AnyView

    /// Creates a new alert with custom views for actions and message.
    ///
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - actions: A closure that returns the alert's action buttons
    ///   - message: A closure that returns the alert's message view
    public init<A: View, M: View>(
      title: String,
      actions: @escaping () -> A,
      message: @escaping () -> M
    ) {
      self.title = title
      self.actions = { AnyView(actions()) }
      self.message = { AnyView(message()) }
    }
  }
}

public extension View {
  /// Adds modal presentation capabilities to a view
  /// - Parameter coordinator: The coordinator managing modal presentations
  /// - Returns: A view with modal presentation capabilities
  @MainActor
  func withModal<C: Coordinator>(_ coordinator: C) -> some View {
    modifier(ModalModifer(state: coordinator.state))
      .environmentObject(coordinator.weakReference)
  }
}

// MARK: - Alert Presentation

public extension Coordinator {
  /// The default title used for alerts when no specific title is provided
  @usableFromInline internal nonisolated static var defaultAlertTitle: String {
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"]
      as? String ?? ""
  }

  /// Presents an alert with custom actions and message
  /// - Parameters:
  ///   - title: The title of the alert
  ///   - message: A closure that returns the message view
  ///   - actions: A closure that returns the alert actions view
  func alert<A: View, M: View>(
    _ title: String = Self.defaultAlertTitle,
    @ViewBuilder _ message: @escaping () -> M,
    @ViewBuilder actions: @escaping () -> A
  ) {
    state.alerts.append(.init(title: title, actions: actions, message: message))
  }

  /// Presents an alert with a default OK button and custom message
  /// - Parameters:
  ///   - title: The title of the alert
  ///   - message: A closure that returns the message view
  @MainActor
  func alert<M: View>(
    _ title: String = Self.defaultAlertTitle,
    @ViewBuilder _ message: @escaping () -> M
  ) {
    state.alerts.append(.init(title: title, actions: { Button("OK") {} }, message: message))
  }

  /// Presents an alert with a default OK button and string message
  /// - Parameters:
  ///   - title: The title of the alert
  ///   - message: The message string
  @MainActor
  func alert(
    _ title: String = Self.defaultAlertTitle,
    message: String
  ) {
    state.alerts.append(.init(title: title, actions: { Button("OK") {} }, message: { Text(message) }))
  }

  /// Presents an alert with custom actions and string message
  /// - Parameters:
  ///   - title: The title of the alert
  ///   - message: The message string
  ///   - actions: A closure that returns the alert actions view
  @MainActor
  func alert<A: View>(
    _ title: String = Self.defaultAlertTitle,
    message: String,
    @ViewBuilder actions: @escaping () -> A
  ) {
    state.alerts.append(.init(title: title, actions: actions, message: { Text(message) }))
  }
}
