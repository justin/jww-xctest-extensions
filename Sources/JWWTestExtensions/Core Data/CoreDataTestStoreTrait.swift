#if swift(>=6.1)
import CoreData
import Foundation
import Testing

/// Supplies a Core Data model to ``CoreDataTestStoreTrait``.
public protocol CoreDataTestModelProvider {
    /// The persistent-container name.
    static var containerName: String { get }

    /// Creates the managed-object model for a test store.
    static func makeManagedObjectModel() -> sending NSManagedObjectModel
}

/// Actor-isolated access to a Core Data test store supplied by a testing trait.
public actor CoreDataTestDatabase {
    private let store: CoreDataTestStore
    private let context: NSManagedObjectContext

    fileprivate init(store: sending CoreDataTestStore) {
        let context = store.container.newBackgroundContext()
        self.store = store
        self.context = context
    }

    /// The SQLite file URL, or `nil` for an in-memory store.
    public var storeURL: URL? {
        store.storeURL
    }

    /// Performs work on the test store's private managed-object context.
    ///
    /// The operation and its return value must be sendable so Core Data values
    /// cannot escape their context's queue.
    ///
    /// - Parameter operation: Work to perform with the managed-object context.
    /// - Returns: The value returned by `operation`.
    public func perform<Value: Sendable>(
        _ operation: @escaping @Sendable (NSManagedObjectContext) throws -> Value
    ) async throws -> Value {
        let context = context
        return try await context.perform {
            try operation(context)
        }
    }

    fileprivate func cleanup() throws {
        try store.cleanup()
    }
}

/// Access to dependencies installed by JWWTestExtensions testing traits.
public enum CoreDataTestContext {
    /// An error raised when a test accesses a dependency outside its trait.
    public enum AccessError: Error {
        /// No Core Data test-store trait applies to the current test.
        case databaseTraitRequired
    }

    /// The database installed for the current test.
    public static var database: CoreDataTestDatabase {
        get throws {
            guard let database = CoreDataTestEnvironment.database else {
                throw AccessError.databaseTraitRequired
            }

            return database
        }
    }
}

/// A Swift Testing trait that provides an isolated Core Data store to each test.
public struct CoreDataTestStoreTrait<Model: CoreDataTestModelProvider>:
    SuiteTrait,
    TestTrait,
    TestScoping,
    Sendable {
    /// Apply the trait separately to every test in a suite.
    public let isRecursive = true

    private let storage: CoreDataTestStore.Storage

    /// Creates a Core Data test-store trait.
    ///
    /// - Parameters:
    ///   - model: The model provider used to create each store.
    ///   - storage: The persistent-store implementation to use.
    public init(
        _ model: Model.Type,
        storage: CoreDataTestStore.Storage = .inMemory
    ) {
        self.storage = storage
    }

    /// Creates the store, runs the test in its scope, and cleans up the store.
    public func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        let store = try await CoreDataTestStore(
            name: Model.containerName,
            managedObjectModel: Model.makeManagedObjectModel(),
            storage: storage
        )
        let database = CoreDataTestDatabase(store: store)

        try await CoreDataTestEnvironment.$database.withValue(database) {
            let operationResult: Result<Void, any Error>
            do {
                operationResult = .success(try await function())
            } catch {
                operationResult = .failure(error)
            }

            do {
                try await database.cleanup()
            } catch {
                if case let .failure(operationError) = operationResult {
                    throw CoreDataTestStore.OperationAndCleanupError(
                        operationError: operationError,
                        cleanupError: error
                    )
                }

                throw error
            }

            if case let .failure(error) = operationResult {
                throw error
            }
        }
    }
}

public extension Trait {
    /// Provides an isolated Core Data store to a test or suite.
    static func coreDataStore<Model: CoreDataTestModelProvider>(
        _ model: Model.Type,
        storage: CoreDataTestStore.Storage = .inMemory
    ) -> CoreDataTestStoreTrait<Model> where Self == CoreDataTestStoreTrait<Model> {
        CoreDataTestStoreTrait(model, storage: storage)
    }
}

private enum CoreDataTestEnvironment {
    @TaskLocal static var database: CoreDataTestDatabase?
}
#endif
