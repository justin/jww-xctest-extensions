# Repository Guidelines

## Project Structure & Module Organization

This Swift package provides XCTest helpers for Apple platforms. `Package.swift`
defines the `JWWTestExtensions` library and supported
deployment targets. Production code lives in `Sources/JWWTestExtensions/`.
General assertions and `XCTestCase` extensions sit at the target root; group
specialized helpers under directories such as `Networking/` and `UI Testing/`.
Tests live in `Tests/JWWTestExtensionsTests/` and should mirror the source
grouping. Core Data test support lives in `Core Data/`; keep it independent of
application-specific models.

## Build, Test, and Development Commands

- `swift build` compiles the package with the active Swift toolchain.
- `swift test` builds and runs the Swift Testing suite.
- `swift test --filter NetworkResponseStubTests` runs one test case while
  iterating.
- `swiftlint lint --strict` checks the rules in `.swiftlint.yml`; install
  SwiftLint locally if the command is unavailable.

Run tests and lint before submitting. For platform-specific APIs, also verify
the affected Apple platform in Xcode when practical.

## Coding Style & Naming Conventions

Use four-space indentation and follow the formatting of nearby Swift code.
Types use `UpperCamelCase`; methods, properties, and local values use
`lowerCamelCase`. Name test functions for the behavior under test, for example
`findingStubByURLRequest()`. Keep public APIs documented with `///` comments,
including parameter behavior where it is
not obvious. Prefer explicit availability annotations for APIs that do not
support every deployment target. Avoid force casts and force tries unless the
reason is documented with a narrow SwiftLint suppression.

## Testing Guidelines

Tests use Swift Testing with `import Testing` and `@testable import
JWWTestExtensions`. Use Swift Testing for all new and updated tests unless a
valid technical constraint requires XCTest; document that reason in the change.
Mark tests with `@Test`, use `#expect` for assertions, and use `#require` to
unwrap prerequisites. Add regression tests for bug fixes and focused unit tests
for new helpers. Keep test fixtures local, deterministic, and independent of
live network services. Prefer composed fixtures such as `CoreDataTestStore`
or its actor-isolated trait instead of test-suite base classes. Cover all
changed behavior.

## Commit & Pull Request Guidelines

Recent commits use concise, capitalized, imperative subjects such as `Add
networking extensions` and `Update to Swift 6`. Keep each commit focused and
omit a trailing period. Pull requests should explain the motivation and
behavioral impact, identify affected platforms, and link relevant issues.
Include the commands run and their results. Add screenshots only for changes
whose UI-testing behavior is best demonstrated visually.
