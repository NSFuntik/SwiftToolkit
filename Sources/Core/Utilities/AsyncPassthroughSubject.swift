import Foundation

// A simple implementation of an asynchronous passthrough subject using Swift's concurrency features.

/**
 An actor that bridges an asynchronous sequence by providing the ability to observe elements and send elements to multiple subscribers.
 */
public actor AsyncPassthroughSubject<Element> {
  /// Array to store continuations for different tasks.
  var tasks: [AsyncStream<Element>.Continuation] = []

  /// Deinitializes the subject by finishing all stored tasks.
  deinit {
    tasks.forEach { $0.finish() }
  }

  /// Initializes an instance of AsyncPassthroughSubject.
  public init() {}

  /**
   Creates an asynchronous stream for receiving notifications of elements.

   - Returns: An `AsyncStream` of type `Element`.
   */
  public func notifications() -> AsyncStream<Element> {
    AsyncStream { [weak self] continuation in
      let task = Task { [weak self] in
        await self?.storeContinuation(continuation)
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }

  /**
   Sends an element to all subscribed tasks.

   - Parameter element: The element to be sent.
   */
  public nonisolated
  func send(_ element: Element) {
    Task { await _send(element) }
  }

  func _send(_ element: Element) {
    let tasks = tasks
    for task in tasks {
      task.yield(element)
    }
  }

  /**
   Stores the provided continuation for future notifications.

   - Parameter continuation: The continuation to be stored.
   */
  func storeContinuation(_ continuation: AsyncStream<Element>.Continuation) {
    tasks.append(continuation)
  }

  /**
   Finishes all pending tasks associated with the subject.
   */
  public nonisolated
  func finish() {
    Task { await _finish() }
  }

  func _finish() {
    let tasks = self.tasks
    self.tasks = []
    for task in tasks {
      task.finish()
    }
  }
}
