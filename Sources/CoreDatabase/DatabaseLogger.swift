//
//  DatabaseLogger.swift
//  CoreDatabase
//
//  Provides comprehensive logging functionality for database operations.

import Combine
import CoreData
import Foundation
import os

// MARK: - DatabaseLogger

/// Enhanced protocol for comprehensive database logging
public protocol DatabaseLogger {
  /// Logs a database operation with detailed context
  func logDatabaseOperation(
    _ operation: String,
    duration: TimeInterval,
    context: [String: Any]?
  )

  /// Logs an error with comprehensive details
  func logError(
    _ error: Error,
    context: [String: Any]?,
    severity: DatabaseLogSeverity
  )

  /// Handles specific types of database errors with custom logic
  func handleError(
    _ error: Error,
    context: NSManagedObjectContext?,
    recoveryStrategy: DatabaseErrorRecoveryStrategy?
  )
}

// MARK: - DatabaseLogSeverity

/// Represents the severity of a database error
public enum DatabaseLogSeverity {
  case info
  case warning
  case error
  case critical
}

// MARK: - DatabaseErrorRecoveryStrategy

/// Defines strategies for recovering from database errors
public enum DatabaseErrorRecoveryStrategy {
  case retry(maxAttempts: Int)
  case rollback
  case reset
  case migrate
  case ignore
}

// MARK: - DefaultDatabaseLogger

public final class DefaultDatabaseLogger: DatabaseLogger {
  private let logger: Logger

  public init(label: String = "com.apple.CoreData") {
    self.logger = Logger(
      subsystem: Bundle.main.bundleIdentifier ?? "com.apple.CoreData",
      category: "CoreDatabase"
    )
  }

  public func logDatabaseOperation(
    _ operation: String,
    duration: TimeInterval,
    context: [String: Any]? = nil
  ) {
    let logMessage = "Operation: \(operation), Duration: \(duration) ms"
    logger.info("\(logMessage, privacy: .public)")

    if let context = context {
      logger.debug("Operation Context: \(context, privacy: .private)")
    }
  }

  public func logError(
    _ error: Error,
    context: [String: Any]? = nil,
    severity: DatabaseLogSeverity = .error
  ) {
    let errorDescription = error.localizedDescription

    switch severity {
    case .info:
      logger.info("\(errorDescription, privacy: .public)")

    case .warning:
      logger.warning("\(errorDescription, privacy: .public)")

    case .error:
      logger.error("\(errorDescription, privacy: .public)")

    case .critical:
      logger.critical("\(errorDescription, privacy: .public)")
    }

    if let context: [String: Any] = context {
      logger.debug("Error Context: \(context, privacy: .private)")
    }
  }

  public func handleError(
    _ error: Error,
    context: NSManagedObjectContext?,
    recoveryStrategy: DatabaseErrorRecoveryStrategy? = .rollback
  ) {
    switch error {
    case let databaseError as DatabaseError:
      handleSpecificDatabaseError(
        databaseError,
        context: context,
        recoveryStrategy: recoveryStrategy
      )
    default:
      logError(error, context: ["NSManagedObjectContext": context as Any], severity: .critical)
    }
  }

  private func handleSpecificDatabaseError(
    _ error: DatabaseError,
    context: NSManagedObjectContext?,
    recoveryStrategy: DatabaseErrorRecoveryStrategy? = nil
  ) {
    switch error {
    case let .validationFailed(reason):
      logError(error, context: ["Validation Reason": reason], severity: .warning)

    case let .saveFailed(underlyingError):
      logError(underlyingError, context: nil, severity: .error)

      switch recoveryStrategy {
      case let .retry(maxAttempts):
        // TODO: Implement retry logic
        switch maxAttempts {
        case 1:
          context?.rollback()
        default:
          break
        }
      case .rollback:
        context?.rollback()
      case .reset:
        context?.reset()
      case .migrate:
        // TODO: Implement migration logic
        break
      case .ignore, .none:
        break
      }

    case let .fetchFailed(underlyingError):
      logError(underlyingError, severity: .error)

    case let .migrationError(underlyingError):
      logError(underlyingError, context: nil, severity: .critical)

    case let .cloudKitSyncError(underlyingError):
      logError(underlyingError, severity: .critical)
    }
  }
}

// MARK: - DatabaseError

/// Represents different types of database errors
public enum DatabaseError: Error {
  case validationFailed(reason: String)
  case saveFailed(underlyingError: Error)
  case fetchFailed(underlyingError: Error)
  case migrationError(underlyingError: Error)
  case cloudKitSyncError(underlyingError: Error)
}

// MARK: - DatabaseLogger Extension

extension DatabaseLogger {
  func handleError(_ error: Error, context: NSManagedObjectContext? = nil) {
    let errorContext: [String: Any]? = context.map { ["NSManagedObjectContext": $0] }

    switch error {
    case let databaseError as DatabaseError:
      switch databaseError {
      case let .validationFailed(reason):
        logError(error, context: errorContext ?? ["Validation Reason": reason], severity: .warning)
      case let .saveFailed(underlyingError):
        logError(underlyingError, context: errorContext, severity: .error)
        context?.rollback()
      case let .fetchFailed(underlyingError):
        logError(underlyingError, context: errorContext, severity: .error)
      case let .migrationError(underlyingError):
        logError(underlyingError, context: errorContext, severity: .critical)
      case let .cloudKitSyncError(underlyingError):
        logError(underlyingError, context: errorContext, severity: .critical)
      }
    default:
      logError(error, context: errorContext, severity: .critical)
    }
  }
}
