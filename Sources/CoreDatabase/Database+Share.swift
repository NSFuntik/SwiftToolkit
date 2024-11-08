//
//  Database+Share.swift
//  Database
//
//  Provides CloudKit sharing functionality for Database.

import os.log
import CoreData
import CloudKit
import Foundation

// CKShare is marked as @unchecked Sendable because it is used in asynchronous contexts
// and we ensure thread safety through other means in our code.
extension CKShare: @unchecked Sendable {}
extension CKShare.Metadata: @unchecked @retroactive Sendable {}

@available(iOS 16.0, *)
public extension Database {
  /// Creates a new CloudKit share for a managed object
  /// - Parameters:
  ///   - destination: Object to share
  ///   - title: Optional share title
  ///   - icon: Optional share icon data
  /// - Returns: Configured CKShare
  func makeShare(
    _ destination: NSManagedObject,
    title: String? = nil,
    icon: Data? = nil) async throws -> CKShare {
    try await makeShare([destination], title: title, icon: icon)
  }

  /// Creates a new CloudKit share for multiple managed objects
  /// - Parameters:
  ///   - destinations: Objects to share
  ///   - title: Optional share title
  ///   - icon: Optional share icon data
  /// - Returns: Configured CKShare
  func makeShare(
    _ destinations: [NSManagedObject],
    title: String? = nil,
    icon: Data? = nil) async throws -> CKShare {
    let (_, share, _) = try await container.share(destinations, to: nil)
    configure(share: share, title: title, icon: icon)
    return share
  }

  /// Configures a CKShare with metadata
  /// - Parameters:
  ///   - share: Share to configure
  ///   - title: Optional share title
  ///   - icon: Optional share icon data
  private func configure(
    share: CKShare,
    title: String?,
    icon: Data?) {
    share[CKShare.SystemFieldKey.title] = title
    share[CKShare.SystemFieldKey.thumbnailImageData] = icon
  }

  /// Removes the current user from share participants
  /// - Parameter share: Share to remove from
  func removeSelfFromParticipants(share: CKShare) async throws {
    guard let store = sharedStore else { return }
    try await container.purgeObjectsAndRecordsInZone(
      with: share.recordID.zoneID,
      in: store)
  }

  /// Creates a new share or fetches existing one
  /// - Parameters:
  ///   - destination: Object to share
  ///   - title: Optional share title
  ///   - icon: Optional share icon data
  /// - Returns: New or existing configured CKShare
  func makeShareOrFetch(
    _ destination: NSManagedObject,
    title: String? = nil,
    icon: Data? = nil) async throws -> CKShare {
    if let share = try container.fetchShares(matching: [destination.objectID])[destination.objectID] {
      configure(share: share, title: title, icon: icon)
      return share
    }
    return try await makeShare(destination, title: title, icon: icon)
  }

  /// Fetches existing share for a managed object
  /// - Parameter destination: Object to fetch share for
  /// - Returns: CKShare if exists
  func fetchShare(_ destination: NSManagedObject) -> CKShare? {
    do {
      return try container.fetchShares(matching: [destination.objectID])[destination.objectID]
    } catch {
      logger.handleError(error, context: destination.managedObjectContext)
    }
    return nil
  }

  /// Checks if an object is shared
  /// - Parameter object: Object to check
  /// - Returns: True if object is shared
  func isShared(_ object: NSManagedObject) -> Bool {
    isShared(object.objectID)
  }

  /// Checks if an object ID is shared
  /// - Parameter objectID: Object ID to check
  /// - Returns: True if object ID is shared
  func isShared(_ objectID: NSManagedObjectID) -> Bool {
    if let persistentStore = objectID.persistentStore {
      return persistentStore == self.sharedStore
    }

    do {
      let shares = try container.fetchShares(matching: [objectID])
      return !shares.isEmpty
    } catch {
      os_log("Failed to check share status: %{public}@", log: .default, type: .error, error.localizedDescription)
    }
    return false
  }

  /// Returns the CloudKit container if configured
  var cloudKitContainer: CKContainer? {
    container.persistentStoreDescriptions
      .compactMap { $0.cloudKitContainerOptions?.containerIdentifier }
      .map { CKContainer(identifier: $0) }
      .first
  }

  /// Accepts a share invitation
  /// - Parameter metadata: Share metadata
  func accept(_ metadata: CKShare.Metadata) async throws {
    guard let sharedStore = sharedStore else {
      throw NSError(domain: "Database", code: -1, userInfo: [NSLocalizedDescriptionKey: "Shared store not configured"])
    }
    try await container.acceptShareInvitations(from: [metadata], into: sharedStore)
  }

  /// Finds the persistent store for a share
  /// - Parameter shareRecordID: Share record ID
  /// - Returns: Matching persistent store if found
  private func persistentStoreForShare(with shareRecordID: CKRecord.ID) -> NSPersistentStore? {
    if let store = privateStore,
       let shares: [CKShare] = try? container.fetchShares(in: store),
       shares.contains(where: { $0.recordID.zoneID == shareRecordID.zoneID }) {
      return store
    }

    if let store = sharedStore,
       let shares: [CKShare] = try? container.fetchShares(in: store),
       shares.contains(where: { $0.recordID.zoneID == shareRecordID.zoneID }) {
      return store
    }

    return nil
  }
}
