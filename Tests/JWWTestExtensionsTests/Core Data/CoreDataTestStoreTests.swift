import CoreData
import Foundation
import Testing
@testable import JWWTestExtensions

struct CoreDataTestStoreTests {
    @Test
    func createsInMemoryStore() async throws {
        let store = try await CoreDataTestStore(
            name: "TestModel",
            managedObjectModel: makeManagedObjectModel()
        )

        let persistentStore = try #require(
            store.container.persistentStoreCoordinator.persistentStores.first
        )
        #expect(persistentStore.type == NSInMemoryStoreType)
        #expect(store.storeURL == nil)

        try store.cleanup()
        #expect(store.container.persistentStoreCoordinator.persistentStores.isEmpty)

        try store.cleanup()
    }

    @Test
    func createsUniqueSQLiteStores() async throws {
        let firstStore = try await CoreDataTestStore(
            name: "TestModel",
            managedObjectModel: makeManagedObjectModel(),
            storage: .sqlite
        )
        let secondStore = try await CoreDataTestStore(
            name: "TestModel",
            managedObjectModel: makeManagedObjectModel(),
            storage: .sqlite
        )
        let firstURL = try #require(firstStore.storeURL)
        let secondURL = try #require(secondStore.storeURL)

        #expect(firstURL != secondURL)
        #expect(FileManager.default.fileExists(atPath: firstURL.path))
        #expect(FileManager.default.fileExists(atPath: secondURL.path))

        try firstStore.cleanup()
        try secondStore.cleanup()

        #expect(!FileManager.default.fileExists(atPath: firstURL.path))
        #expect(!FileManager.default.fileExists(atPath: secondURL.path))
    }

    @Test
    func scopedStoreCleansUpBeforeReturning() async throws {
        let storeURL = try await CoreDataTestStore.withStore(
            name: "TestModel",
            managedObjectModel: makeManagedObjectModel(),
            storage: .sqlite
        ) { store in
            let storeURL = try #require(store.storeURL)
            #expect(FileManager.default.fileExists(atPath: storeURL.path))
            return storeURL
        }

        #expect(!FileManager.default.fileExists(atPath: storeURL.path))
    }

    private func makeManagedObjectModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = "Item"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let identifier = NSAttributeDescription()
        identifier.name = "identifier"
        identifier.attributeType = .UUIDAttributeType
        identifier.isOptional = false

        entity.properties = [identifier]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }
}
