#if compiler(>=6.1)
import CoreData
import Testing
@testable import JWWTestExtensions

@Suite(.coreDataStore(CoreDataStoreTraitTestModel.self, storage: .sqlite))
struct CoreDataTestStoreTraitTests {
    @Test
    func providesSQLiteStore() async throws {
        let database = try CoreDataTestContext.database
        let storeURL = await database.storeURL

        #expect(storeURL != nil)
    }

    @Test
    func performsWorkOnManagedObjectContext() async throws {
        let database = try CoreDataTestContext.database

        let count = try await database.perform { context in
            let entity = try #require(NSEntityDescription.entity(
                forEntityName: "Item",
                in: context
            ))
            let item = NSManagedObject(entity: entity, insertInto: context)
            item.setValue(UUID(), forKey: "identifier")
            try context.save()

            let request = NSFetchRequest<NSManagedObject>(entityName: "Item")
            return try context.count(for: request)
        }

        #expect(count == 1)
    }
}

struct CoreDataTestContextTests {
    @Test
    func requiresTrait() {
        #expect(throws: CoreDataTestContext.AccessError.self) {
            try CoreDataTestContext.database
        }
    }
}

private enum CoreDataStoreTraitTestModel: CoreDataTestModelProvider {
    static let containerName = "TraitTestModel"

    static func makeManagedObjectModel() -> sending NSManagedObjectModel {
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
#endif
