//
//  OCRModelSelectionTests.swift
//  SnapzyTests
//
//  Tests for OCRModelSelection backward compatibility and safe fallback.
//

import XCTest
@testable import Snapzy

final class OCRModelSelectionTests: XCTestCase {

  func testSafelyDecodesOldCustomOrUnknownValuesToBuiltIn() throws {
    // Old custom model ID string
    let customJSON = Data("\"custom:12345678-1234-1234-1234-123456789abc\"".utf8)
    let decodedCustom = try JSONDecoder().decode(OCRModelSelection.self, from: customJSON)
    XCTAssertEqual(decodedCustom, .builtIn)

    // Legacy downloadable model string
    let dlJSON = Data("\"dl:old-model\"".utf8)
    let decodedDL = try JSONDecoder().decode(OCRModelSelection.self, from: dlJSON)
    XCTAssertEqual(decodedDL, .builtIn)

    // Arbitrary unknown string
    let unknownJSON = Data("\"unknown-remote-engine\"".utf8)
    let decodedUnknown = try JSONDecoder().decode(OCRModelSelection.self, from: unknownJSON)
    XCTAssertEqual(decodedUnknown, .builtIn)

    // Standard builtin string
    let builtinJSON = Data("\"builtin\"".utf8)
    let decodedBuiltin = try JSONDecoder().decode(OCRModelSelection.self, from: builtinJSON)
    XCTAssertEqual(decodedBuiltin, .builtIn)
  }

  func testPersistedValueInitializerAlwaysYieldsBuiltIn() {
    XCTAssertEqual(OCRModelSelection(persistedValue: "builtin"), .builtIn)
    XCTAssertEqual(OCRModelSelection(persistedValue: "custom:550e8400-e29b-41d4-a716-446655440000"), .builtIn)
    XCTAssertEqual(OCRModelSelection(persistedValue: "openai:gpt-4o"), .builtIn)
    XCTAssertEqual(OCRModelSelection(persistedValue: ""), .builtIn)
  }

  @MainActor
  func testResolverAlwaysResolvesToVisionProvider() {
    let resolver = OCRModelResolver()
    let resolution = resolver.resolveStoredSelection()
    XCTAssertEqual(resolution.selection, .builtIn)
    XCTAssertEqual(resolution.provider.engine, .vision)
  }
}
