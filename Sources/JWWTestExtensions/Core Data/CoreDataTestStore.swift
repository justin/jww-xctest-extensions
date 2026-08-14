import CoreData
import Foundation

/// An isolated Core Data store for use in tests.
///
/// Each instance owns one persistent container. SQLite-backed instances also
/// own a unique temporary directory, allowing independent tests to run in
/// parallel without sharing database files.
public final class CoreDataTestStore {
    /// The persistent-store implementation used by a test store.
    public enum Storage: Sendable {
        /// A transient store intended for ordinary unit tests.
        case inMemory

        /// A temporary SQLite store intended for persistence and integration tests.
        case sqlite
    }

    /// An error containing failures from both an operation and its cleanup.
    public struct OperationAndCleanupError: Error {
        /// The error thrown by the scoped operation.
        public let operationError: any Error

        /// The error thrown while cleaning up the store.
        public let cleanupError: any Error
    }

    /// The loaded persistent container.
    public let container: NSPersistentContainer

    /// The implementation used by the persistent store.
    public let storage: Storage

    /// The SQLite file URL, or `nil` for an in-memory store.
    public let storeURL: URL?

    private let directoryURL: URL?
    private var isCleanedUp = false

    /// Creates and loads an isolated Core Data store.
    ///
    /// - Parameters:
    ///   - name: The name of the persistent container.
    ///   - managedObjectModel: The model loaded by the persistent container.
    ///   - storage: The persistent-store implementation to use.
    public init(
        name: String,
        managedObjectModel: sending NSManagedObjectModel,
        storage: Storage = .inMemory
    ) async throws {
        self.storage = storage
        container = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)

        switch storage {
        case .inMemory:
            directoryURL = nil
            storeURL = nil

            let storeDescription = NSPersistentStoreDescription()
            storeDescription.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [storeDescription]

        case .sqlite:
            let directoryURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("JWWTestExtensions", isDirectory: true)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            let storeURL = directoryURL.appendingPathComponent("\(name).sqlite")

            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

            self.directoryURL = directoryURL
            self.storeURL = storeURL
            container.persistentStoreDescriptions = [
                NSPersistentStoreDescription(url: storeURL)
            ]
        }

        do {
            try await loadPersistentStores()
        } catch {
            try? removeOwnedDirectory()
            throw error
        }
    }

    deinit {
        try? cleanup()
    }

    /// Removes the loaded persistent store and any temporary files it owns.
    ///
    /// Calling this method more than once has no effect.
    public func cleanup() throws {
        guard !isCleanedUp else {
            return
        }

        for persistentStore in container.persistentStoreCoordinator.persistentStores {
            guard let url = persistentStore.url else {
                continue
            }

            try container.persistentStoreCoordinator.remove(persistentStore)
            guard persistentStore.type != NSInMemoryStoreType else {
                continue
            }

            try container.persistentStoreCoordinator.destroyPersistentStore(
                at: url,
                ofType: persistentStore.type,
                options: persistentStore.options
            )
        }

        try removeOwnedDirectory()
        isCleanedUp = true
    }

    /// Runs an operation with an isolated store and cleans it up before returning.
    ///
    /// Use this helper when cleanup failures need to be reported by the test.
    /// If both the operation and cleanup fail, this method throws
    /// ``OperationAndCleanupError`` containing both errors.
    ///
    /// - Parameters:
    ///   - name: The name of the persistent container.
    ///   - managedObjectModel: The model loaded by the persistent container.
    ///   - storage: The persistent-store implementation to use.
    ///   - operation: The operation to perform with the loaded store.
    /// - Returns: The value returned by `operation`.
    public static func withStore<Output>(
        name: String,
        managedObjectModel: sending NSManagedObjectModel,
        storage: Storage = .inMemory,
        operation: (CoreDataTestStore) async throws -> Output
    ) async throws -> Output {
        let store = try await CoreDataTestStore(
            name: name,
            managedObjectModel: managedObjectModel,
            storage: storage
        )

        let operationResult: Result<Output, any Error>
        do {
            operationResult = .success(try await operation(store))
        } catch {
            operationResult = .failure(error)
        }

        do {
            try store.cleanup()
        } catch {
            if case let .failure(operationError) = operationResult {
                throw OperationAndCleanupError(
                    operationError: operationError,
                    cleanupError: error
                )
            }

            throw error
        }

        switch operationResult {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }

    private func loadPersistentStores() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            container.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func removeOwnedDirectory() throws {
        guard let directoryURL,
              FileManager.default.fileExists(atPath: directoryURL.path) else {
            return
        }

        try FileManager.default.removeItem(at: directoryURL)
    }
}
