//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 17.05.2024.
//

import Combine
import SwiftUI

// MARK: - ErrorAlertConvertible

/// This protocol can be implemented by error types that can be
/// used together with an ``ErrorAlerter``.
///
/// This makes it possible to specify display content for error
/// types that are meant to be presented to users.
public protocol ErrorAlertConvertible: Error {
  /// The title to display in the alert.
  var errorTitle: String { get }

  /// The message to display in the alert.
  var errorMessage: String { get }

  /// The text to use for the alert button.
  var errorButtonText: String { get }
}

extension ErrorAlertConvertible {
  /// Create an error `Alert`.
  public var errorAlert: Alert {
    Alert(
      title: Text(errorTitle),
      message: Text(errorMessage),
      dismissButton: .default(Text(errorButtonText))
    )
  }
}

// MARK: - ErrorAlerter

/// This protocol can be implemented by anything that can alert
/// errors, e.g. a view that performs a throwing async function.
///
/// By implementing the protocol, types get access to new alert
/// functions as well as the convenient ``tryWithErrorAlert(_:)``
/// function, that makes it possible to trigger async functions
/// and alert any errors that occur.
///
/// If you throw errors that conform to ``ErrorAlertConvertible``
/// you get full control over what's alerted.
public protocol ErrorAlerter {
  var alert: AlertContext { get }
}

@MainActor
extension ErrorAlerter {
  /**
   Alert the provided error.

   If the error is an ``ErrorAlertConvertible``, then this
   presents its ``ErrorAlertConvertible/errorAlert``, else
   the error's `localizedDescription` is alerted.
   */
  public func alert(
    error: Error,
    okButtonText: String = "OK"
  ) {
    if let error = error as? ErrorAlertConvertible {
      return alert.present(error.errorAlert)
    }
    alert.present(
      Alert(
        title: Text(error.localizedDescription),
        dismissButton: .default(Text(okButtonText))
      )
    )
  }
}

extension ErrorAlerter {
  /// This typealias describes an async operation.
  public typealias AsyncOperation = () async throws -> Void

  /// This typealias describes a block completion.
  public typealias BlockCompletion<ErrorType: Error> = (BlockResult<ErrorType>) -> Void

  /// This typealias describes a block completion result.
  public typealias BlockResult<ErrorType: Error> = Result<Void, ErrorType>

  /// This typealias describes a block operation.
  public typealias BlockOperation<ErrorType: Error> = (BlockCompletion<ErrorType>) -> Void

  /// Alert the provided error asynchronously.
  public func alertAsync(
    error: Error,
    okButtonText: String = "OK"
  ) {
    DispatchQueue.main.async {
      alert(
        error: error,
        okButtonText: okButtonText
      )
    }
  }

  /// Try to perform a block-based operation, and alert if
  /// this operation fails in any way.
  public func tryWithErrorAlert<ErrorType: Error>(
    _ operation: @escaping BlockOperation<ErrorType>,
    completion: @escaping BlockCompletion<ErrorType>
  ) {
    operation { result in
      switch result {
      case let .failure(error): alertAsync(error: error)
      case .success: break
      }
      completion(result)
    }
  }

  /// Try to perform an async operation, and alert if this
  /// operation fails in any way.
  ///
  /// This function wraps an async operation in a task and
  /// alerts any errors that are thrown.
  public func tryWithErrorAlert(_ operation: @escaping AsyncOperation) {
    Task {
      do {
        try await operation()
      } catch {
        await alert(error: error)
      }
    }
  }
}

// MARK: - AlertContext

/// This context can be used to present alerts in a dynamic way.
///
/// To use this class, just create a `@StateObject` instance in
/// your presenting view and bind the context to that view:
///
/// ```swift
/// extension Alert {
///
/// static let customAlert = Alert(title: "Hello, world!")
/// }
///
/// struct MyView: View {
///
/// @StateObject var context = AlertContext()
///
/// var body: some View {
/// Button("Show alert") {
/// context.present(.customAlert)
/// }
/// .alert(context)
/// }
/// }
/// ```
///
/// In the code above, we create a custom, static `Alert` value
/// to easily let us share and reuse alerts in an app or domain.
///
/// This view modifier will also inject the provided context as
/// an environment object into the view hierarchy, to let other
/// views in the same view hierarchy reuse the same context.
public class AlertContext: PresentationContext<Alert> {
  public func present(
    _ alert: @autoclosure @escaping () -> Alert
  ) {
    presentContent(alert())
  }
}

extension View {
  /// Bind an ``AlertContext`` to the view.
  ///
  /// This also injects this context as environment object.
  public func alert(_ context: AlertContext) -> some View {
    alert(
      isPresented: context.isActiveBinding,
      content: context.content ?? { Alert(title: Text("")) }
    )
    .environmentObject(context)
  }
}

// MARK: - PresentationContext

/// This class is shared by presentation-specific contexts, and
/// can be used to present different views with one context.
///
/// To use the context, first create an observed instance, then
/// bind it to a view using custom view modifiers. You can also
/// set up a global context and pass it into the view hierarchy
/// as an environment object.
open class PresentationContext<Content>: ObservableObject {
  public init() {}

  @Published
  public var isActive = false

  @Published
  public internal(set) var content: (() -> Content)? {
    didSet { isActive = content != nil }
  }

  public var isActiveBinding: Binding<Bool> {
    .init(
      get: { self.isActive },
      set: { self.isActive = $0 }
    )
  }

  public func dismiss() {
    DispatchQueue.main.async {
      self.isActive = false
    }
  }

  public func presentContent(_ content: @autoclosure @escaping () -> Content) {
    DispatchQueue.main.async {
      self.content = content
    }
  }
}
