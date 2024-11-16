//
//  AsyncButton.swift
//  NSSwift
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//

import SwiftUI

// MARK: - AsyncButton

/// A view representing an asynchronous button that performs an action when tapped.
///
/// The `AsyncButton` takes an `action` that is an asynchronous function and can also accept a `cancellation` parameter to determine the cancellation behavior.
/// The button displays a label, and it shows a progress view while the action is running.
public struct AsyncButton<Label: View, Trigger: Equatable>: View {
  var cancellation: Trigger?
  let action: () async -> Void
  let label: Label
  @State private var task: Task<Void, Never>?
  @State private var isRunning = false
  /// Creates the async button with a specified cancellation trigger and action.
  ///
  /// - Parameters:
  ///   - cancellation: The cancellation trigger, defaulting to `false`.
  ///   - action: The asynchronous action to perform when the button is pressed.
  ///   - label: A view builder that constructs the label for the button.
  init(
    cancellation: Trigger = false,
    action: @escaping () async -> Void,
    @ViewBuilder label: () -> Label
  ) {
    self.cancellation = cancellation
    self.action = action
    self.label = label()
  }

  /// Creates the async button with a specified cancellation trigger and a synchronous action.
  ///
  /// - Parameters:
  ///   - cancellation: The cancellation trigger, defaulting to `false`.
  ///   - action: The synchronous action to perform when the button is pressed.
  ///   - label: A view builder that constructs the label for the button.
  init(
    cancellation: Trigger = false,
    action: Void,
    @ViewBuilder label: () -> Label
  ) {
    self.cancellation = cancellation
    self.action = { action }
    self.label = label()
  }

  /// The view representing the button.
  ///
  /// When tapped, the button executes the asynchronous action and displays a progress indicator while the action is running.
  public var body: some View {
    Button {
      isRunning = true
      task = Task {
        await action()
        isRunning = false
      }
    } label: {
      label
    }
    .disabled(isRunning)
    .opacity(isRunning ? 0.5 : 1)
    .shimmering(active: isRunning)
    .if(isRunning) {
      $0.overlay(alignment: .center, content: { ProgressView().progressViewStyle(.circular).padding() })
    }
    .onChange(of: cancellation) { _ in
      task?.cancel()
    }
  }
}

/// A specialized extension for `AsyncButton` where the Trigger type is `Never`.
///
/// This extension provides a more simplified initializer for cases where no cancellation is required.
extension AsyncButton where Trigger == Never {
  /// Creates the async button without a cancellation trigger.
  ///
  /// - Parameters:
  ///   - action: The asynchronous action to perform when the button is pressed.
  ///   - label: A view builder that constructs the label for the button.
  public init(
    action: @escaping () async -> Void,
    @ViewBuilder label: () -> Label
  ) {
    self.action = action
    self.label = label()
  }
}
