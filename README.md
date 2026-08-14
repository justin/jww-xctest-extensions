# JWWTestExtensions

A set of helpers and types I use for test bundles on Apple platforms.

## Core Data Test Stores

`CoreDataTestStore` creates a loaded, isolated persistent container for each
test. In-memory stores are the default and are appropriate for most unit tests.
Use SQLite when testing persistence, migrations, or SQLite-specific behavior.

```swift
import CoreData
import Testing
import JWWTestExtensions

struct RepositoryTests {
    let database: CoreDataTestStore

    init() async throws {
        database = try await CoreDataTestStore(
            name: "Model",
            managedObjectModel: TestModel.make(),
            storage: .sqlite
        )
    }

    @Test
    func savesRecord() throws {
        let context = database.container.viewContext
        // Exercise the repository with context.
    }
}
```

Swift Testing creates a separate suite instance for each test, so each SQLite
fixture receives its own temporary directory and can run in parallel. The
fixture performs best-effort cleanup when it is released. Use `withStore` when
cleanup errors must fail the test:

```swift
try await CoreDataTestStore.withStore(
    name: "Model",
    managedObjectModel: TestModel.make()
) { database in
    // Exercise code with database.container.
}
```

Core Data objects retain their normal queue-confinement requirements. Use
`perform` or `performAndWait` on managed object contexts rather than passing
contexts between concurrent tasks.

### Swift Testing Trait

With Swift 6.1 or later, `CoreDataTestStoreTrait` can manage the same fixture
lifecycle for every test in a suite. Define a model provider in the test target:

```swift
enum TestModelProvider: CoreDataTestModelProvider {
    static let containerName = "Model"

    static func makeManagedObjectModel() -> sending NSManagedObjectModel {
        TestModel.make()
    }
}
```

Apply the trait and access its actor-isolated database through
`CoreDataTestContext`:

```swift
@Suite(.coreDataStore(TestModelProvider.self, storage: .sqlite))
struct RepositoryTests {
    @Test
    func savesRecord() async throws {
        let database = try CoreDataTestContext.database

        try await database.perform { context in
            let repository = Repository(context: context)
            try repository.saveRecord()
        }
    }
}
```

The trait creates a separate store for every test and reports setup or cleanup
errors through Swift Testing. Prefer direct `CoreDataTestStore` composition
when a test needs access to the persistent container or multiple contexts.

## License

Copyright 2024 Justin Williams. Licensed under the MIT license.
