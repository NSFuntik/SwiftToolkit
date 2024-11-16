import Foundation

/// Key storage for associated objects
@MainActor private var stateKey: UInt8 = 0
@MainActor private var weakReferenceKey: UInt8 = 1

extension Coordinator {
  /// Returns the coordinator's navigation state.
  @MainActor
  public var state: NavigationState {
    if let state = objc_getAssociatedObject(self, &stateKey) as? NavigationState {
      return state
    } else {
      let state = NavigationState()
      objc_setAssociatedObject(
        self,
        &stateKey,
        state,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
      return state
    }
  }

  /// Returns a weak reference wrapper for this coordinator.
  @MainActor
  public var weakReference: Navigation<Self> {
    if let reference = objc_getAssociatedObject(self, &weakReferenceKey) as? Navigation<Self> {
      return reference
    } else {
      let reference = Navigation(self)
      objc_setAssociatedObject(
        self,
        &weakReferenceKey,
        reference,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
      return reference
    }
  }
}
