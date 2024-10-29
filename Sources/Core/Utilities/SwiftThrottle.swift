import Foundation

// MARK: - Throttle

// This throttle is intended to prevent the program from crashing with
// too many requests or is used for saving computer resources.
//
// ** Swift Throttle is not designed for operations that require high time accuracy **
//
public class Throttle {
  // Properties

  // MARK: - PROPERTY

  /// Setup with these values to control the throttle behavior
  /// - minimumDelay >= 0.5 second is suggested
  public private(set) var minimumDelay: TimeInterval
  public private(set) var workingQueue: DispatchQueue

  /// These values control throttle behavior
  public private(set) var lastExecute: Date?
  public private(set) var lastRequestWasCanceled = false
  public private(set) var scheduled = false

  /// Lock when dispatching job to execution
  private var executeLock = NSLock()

  /// Lock when setting jobs, required by thread-safe design
  private var assignmentLock = NSLock()
  private var _assignment: (() -> Void)?

  // Computed Properties

  public private(set) var assignment: (() -> Void)? {
    set {
      self.assignmentLock.lock()
      defer { assignmentLock.unlock() }
      self._assignment = newValue
    }
    get {
      self.assignmentLock.lock()
      defer { assignmentLock.unlock() }
      return self._assignment
    }
  }

  // Lifecycle

  // MARK: - INIT

  /// Create a throttle
  /// - Parameters:
  ///   - minimumDelay: in seconds
  ///   - queue: the queue that job will be executed on, default to main
  public init(
    minimumDelay delay: TimeInterval,
    queue: DispatchQueue = DispatchQueue.main) {
    self.minimumDelay = delay
    self.workingQueue = queue

    #if DEBUG
      if self.minimumDelay < 0.5 {
        // We suggest minimumDelay to be at least 0.5 second
        debugPrint("[SwiftThrottle] minimumDelay(\(self.minimumDelay)) less than 0.5s will be inaccurate, last callback not guaranteed")
      }
    #endif
  }

  // Functions

  // MARK: - API

  /// Update property minimumDelay
  /// - Parameter interval: in seconds
  public func updateMinimumDelay(interval: Double) {
    self.executeLock.lock()
    defer { executeLock.unlock() }
    self.minimumDelay = interval
  }

  /// Assign job to throttle
  /// - Parameter job: call block
  public func throttle(job: (() -> Void)?) {
    self.realThrottle(job: job, useAssignment: false)
  }

  // MARK: - BACKEND

  /// Check nothing but execute
  /// - Parameter capturedJob: block to execute
  private func releaseExec(capturedJob: @escaping (() -> Void)) {
    self.lastExecute = Date()
    self.workingQueue.async {
      capturedJob()
    }
  }

  /// Throttle is working here
  /// - Parameters:
  ///   - job: block that was required to execute
  ///   - useAssignment: shall we overwrite assigned job?
  private func realThrottle(job: (() -> Void)?, useAssignment: Bool) {
    // Lock down everything when resigning job
    self.executeLock.lock()
    defer { executeLock.unlock() }

    // If called from rescheduled job, cancel job overwrite
    var capturedJobDecision: (() -> Void)?
    if !useAssignment {
      // Resign job every time calling from user
      self.assignment = job
      capturedJobDecision = job
    } else {
      capturedJobDecision = self.assignment
    }
    guard let capturedJob = capturedJobDecision else { return }

    if let lastExec = lastExecute {
      // Executed before, value negative
      let timeBetween = -lastExec.timeIntervalSinceNow

      if timeBetween < self.minimumDelay {
        // The throttle will be reprogrammed once for future execution
        self.lastRequestWasCanceled = true
        if !self.scheduled {
          self.scheduled = true
          let dispatchTime = self.minimumDelay - timeBetween + 0.01
          // Preventing trigger failures
          // This is where the inaccuracy comes from
          self.workingQueue.asyncAfter(deadline: .now() + dispatchTime) {
            self.realThrottle(job: nil, useAssignment: true)
            self.scheduled = false
          }
        }
      } else {
        // Throttle release to execution
        self.releaseExec(capturedJob: capturedJob)
      }
    } else {
      // Never called before, release to execution
      self.releaseExec(capturedJob: capturedJob)
    }
  }
}
