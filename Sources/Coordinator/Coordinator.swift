import Combine
import Foundation
import SwiftUI

// MARK: - Navigation

/// A type that manages navigation and modal presentation in a SwiftUI application.
///
/// Example of implementation:
/// ```swift
/// final class SomeCoordinator: NavigationModalCoordinator {
///    enum Screen: ScreenProtocol {
///       case screen1
///       case screen2
///       case screen3
///    }
///
///    func destination(for screen: Screen) -> some View {
///       switch screen {
///           case .screen1: Screen1View()
///           case .screen2: Screen2View()
///           case .screen3: Screen3View()
///       }
///    }
///
///    enum ModalFlow: ModalProtocol {
///       case modalScreen1
///       case modalFlow(ChildCoordinator = .init())
///    }
///
///    func destination(for flow: ModalFlow) -> some View {
///       switch flow {
///          case .modalScreen1: Modal1View()
///          case .modalFlow(let coordinator): coordinator.view(for: .rootScreen)
///       }
///    }
/// }
/// ```
///
/// ## Usage
/// Show view in SwiftUI hierarchy with screen1 as root view:
/// ```swift
/// coordinator.view(for: .screen1)
/// ```
///
/// Push view in navigation stack:
/// ```swift
/// coordinator.present(.screen1)
/// ```
///
/// Present modal view:
/// ```swift
/// coordinator.present(.modalFlow())
/// ```
///
/// The Navigation class serves as a weak reference wrapper for coordinator objects,
/// ensuring proper memory management while maintaining SwiftUI state observation.
@MainActor
public final class Navigation<C: Coordinator>: ObservableObject {
  /// The wrapped coordinator instance
  private(set) weak var object: C?
  private var observer: AnyCancellable?

  /// Creates a new navigation instance wrapping the specified coordinator
  /// - Parameter object: The coordinator to be wrapped
  public init(_ object: C) {
    self.object = object

    observer = object.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
  }

  /// Provides access to the wrapped coordinator
  /// - Returns: The wrapped coordinator instance
  public func callAsFunction() -> C { object! }
}

// MARK: - Coordinator

/// A protocol that defines the core functionality of a coordinator
///
/// Coordinators are responsible for managing navigation flow and modal presentations
/// in a SwiftUI application. They maintain state and provide methods for navigation
/// control.
@MainActor
public protocol Coordinator: ObservableObject, Hashable, Sendable {}

public extension Coordinator {
  /// Hashes the coordinator instance
  /// - Parameter hasher: The hasher to use for combining the instance's essential components
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  /// Compares two coordinator instances for equality
  /// - Parameters:
  ///   - lhs: The first coordinator to compare
  ///   - rhs: The second coordinator to compare
  /// - Returns: true if the coordinators are equal
  nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.hashValue == rhs.hashValue
  }

  /// Dismisses the current modal navigation
  @MainActor
  func dismiss() {
    state.presentedBy?.dismissPresented()
  }

  /// Dismisses any modal navigation presented over the current navigation
  @MainActor
  func dismissPresented() {
    state.modalPresented = nil
  }

  /// Removes the topmost screen from the navigation stack
  @MainActor
  func pop() {
    state.path.removeLast()
  }

  /// Removes all screens from the navigation stack except the root
  @MainActor
  func popToRoot() {
    state.path.removeAll()
  }
}

// MARK: - Modal Presentation

@MainActor
extension Coordinator {
  /// Presents a modal view with the specified presentation configuration
  /// - Parameters:
  ///   - presentation: The modal presentation configuration
  ///   - resolve: The resolution strategy for handling existing presentations
  func present(_ presentation: ModalPresentation,
               resolve: PresentationResolve = .overAll) {
    if let presentedCoordinator = state.modalPresented?.coordinator {
      switch resolve {
      case .replaceCurrent:
        dismissPresented()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
          self?.present(presentation, resolve: resolve)
        }
      case .overAll:
        presentedCoordinator.present(presentation, resolve: resolve)
      }
    } else {
      presentation.coordinator.state.presentedBy = self
      state.modalPresented = presentation
    }
  }
}

// MARK: - Constants and Protocols

/// Commonly used coordinate spaces for navigation and modal views
public extension CoordinateSpace {
  /// Coordinate space for navigation controller views
  static let navController = "CoordinatorSpaceNavigationController"
  /// Coordinate space for modal presentation views
  static let modal = "CoordinatorSpaceModal"
}

// MARK: - CustomCoordinator

/// A protocol for coordinators that manage a single destination view
public protocol CustomCoordinator: Coordinator {
  associatedtype DestinationView: View

  /// Returns the destination view for this coordinator
  func destination() -> DestinationView
}

public extension CustomCoordinator {
  /// The root view of the coordinator with modal presentation capability
  @MainActor
  var rootView: some View {
    destination().withModal(self)
  }
}

// MARK: - View Modifiers

public extension View {
  /// Adds navigation capabilities to a view
  /// - Parameter coordinator: The navigation coordinator
  /// - Returns: A view with navigation capabilities
  @MainActor
  func withNavigation<C: NavigationCoordinator>(_ coordinator: C) -> some View {
    modifier(NavigationModifer(coordinator: coordinator))
  }
}

// MARK: - ScreenProtocol

/// A protocol that defines the requirements for a screen in a navigation flow
public protocol ScreenProtocol: Hashable {}

// MARK: - NavigationCoordinator

/// A protocol for coordinators that manage navigation flows
public protocol NavigationCoordinator: Coordinator {
  associatedtype Screen: ScreenProtocol
  associatedtype ScreenView: View

  /// Returns the destination view for the specified screen
  @ViewBuilder func destination(for screen: Screen) -> ScreenView
}

public extension NavigationCoordinator {
  /// Presents a new screen in the navigation stack
  /// - Parameter screen: The screen to present
  @MainActor
  func present(_ screen: Screen) {
    state.path.append(screen)
  }

  /// Pops the navigation stack to a screen that matches the condition
  /// - Parameter condition: A closure that returns true for the target screen
  /// - Returns: true if a matching screen was found and navigation was performed
  @MainActor
  @discardableResult
  func popTo(where condition: (Screen) -> Bool) -> Bool {
    if let index = state.path.firstIndex(where: {
      if let screen = $0 as? Screen {
        return condition(screen)
      }
      return false
    }) {
      state.path.removeLast(state.path.count - index - 1)
      return true
    }
    return false
  }

  /// Pops the navigation stack to a specific screen
  /// - Parameter element: The target screen
  /// - Returns: true if the screen was found and navigation was performed
  @MainActor
  @discardableResult
  func popTo(_ element: Screen) -> Bool {
    popTo(where: { $0 == element })
  }
}

public extension NavigationCoordinator {
  /// Returns a view for the specified screen with navigation and modal capabilities
  /// - Parameter screen: The screen to create a view for
  /// - Returns: A view configured with navigation and modal presentation support
  @MainActor
  func view(for screen: Screen) -> some View {
    destination(for: screen)
      .withNavigation(self)
      .withModal(self)
  }
}

// MARK: - NavigationModifer

private struct NavigationModifer<Coordinator: NavigationCoordinator>: ViewModifier {
  let coordinator: Coordinator
  @ObservedObject var state: NavigationState

  init(coordinator: Coordinator) {
    self.coordinator = coordinator
    self.state = coordinator.state
  }

  public func body(content: Content) -> some View {
    Group {
      if #available(iOS 16.0, *, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
        modernNavigationStack(content: content)
      } else {
        legacyNavigationView(content: content)
      }
    }
    .coordinateSpace(name: CoordinateSpace.navController)
  }

  @available(iOS 16.0, *, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @ViewBuilder
  private func modernNavigationStack(content: Content) -> some View {
    NavigationStack(path: $state.path) { [weak coordinator] in
      content
        .navigationDestination(for: AnyHashable.self) { value in
          if let screen = value as? Coordinator.Screen {
            coordinator?.destination(for: screen)
          }
        }
    }
  }

  @ViewBuilder
  private func legacyNavigationView(content: Content) -> some View {
    NavigationView {
      content
        .background(
          NavigationLink(
            isActive: Binding(
              get: { !state.path.isEmpty },
              set: { isActive in
                if !isActive {
                  state.path.removeAll()
                }
              }),
            destination: {
              if let lastScreen = state.path.last as? Coordinator.Screen {
                coordinator.destination(for: lastScreen)
                  .background(
                    recursiveNavigationLinks()
                  )
              }
            },
            label: { EmptyView() })
        )
    }
    .navigationViewStyle(.automatic)
  }

  @ViewBuilder
  private func recursiveNavigationLinks() -> some View {
    ForEach(Array(state.path.dropLast().enumerated()), id: \.offset) { index, screen in
      if let typedScreen = screen as? Coordinator.Screen {
        NavigationLink(
          isActive: Binding(
            get: { index < state.path.count - 1 },
            set: { isActive in
              if !isActive {
                state.path.removeSubrange((index + 1)...)
              }
            }),
          destination: {
            coordinator.destination(for: typedScreen)
          },
          label: { EmptyView() })
      }
    }
  }
}

// MARK: - NavigationState

/// Coordinator navigation state. Stores current navigation path and a reference to presented child navigation with reference to parent coordinator
public final class NavigationState: ObservableObject {
  /// Current navigation path
  @Published public var path: [AnyHashable] = []

  /// Modal flow presented over current navigation
  @Published public internal(set) var modalPresented: ModalPresentation?

  /// Currently presented alerts
  @Published var alerts: [Alert] = []

  /// Parent coordinator presented current navigation modally
  public internal(set) weak var presentedBy: (any Coordinator)?

  private var observers: [AnyCancellable] = []

  @MainActor
  public init() {
    $path.sink { [weak self] _ in
      self?.closeKeyboard()
    }.store(in: &observers)

    $modalPresented.sink { [weak self] _ in
      self?.closeKeyboard()
    }.store(in: &observers)
  }

  @MainActor private func closeKeyboard() {
    #if os(macOS)
      NSApp.keyWindow?.makeFirstResponder(nil)
    #else
      UIApplication.shared.resignFirstResponder()
    #endif
  }
}
