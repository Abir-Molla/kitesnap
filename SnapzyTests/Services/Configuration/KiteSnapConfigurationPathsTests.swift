//
//  KiteSnapConfigurationPathsTests.swift
//  KiteSnapTests
//
//  Tests for user-managed TOML configuration paths.
//

import Darwin
import XCTest
@testable import Snapzy

@MainActor
final class KiteSnapConfigurationPathsTests: XCTestCase {
  func testSuggestedConfigURLUsesProvidedHomeDirectory() {
    let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)

    let url = KiteSnapConfigurationPaths.suggestedConfigURL(homeDirectory: home)

    XCTAssertEqual(url.path, "/Users/example/.config/snapzy/config.toml")
  }

  func testSuggestedConfigDirectoryURLUsesProvidedHomeDirectory() {
    let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)

    let url = KiteSnapConfigurationPaths.suggestedConfigDirectoryURL(homeDirectory: home)

    XCTAssertEqual(url.path, "/Users/example/.config/snapzy")
  }

  func testCollapsingHomePathConvertsAbsolutePathToTilde() {
    let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)

    XCTAssertEqual(
      KiteSnapConfigurationPaths.collapsingHomePath("/Users/example/Desktop", homeDirectory: home),
      "~/Desktop"
    )
    XCTAssertEqual(
      KiteSnapConfigurationPaths.collapsingHomePath("/Users/example", homeDirectory: home),
      "~"
    )
    XCTAssertEqual(
      KiteSnapConfigurationPaths.collapsingHomePath("/tmp/snapzy", homeDirectory: home),
      "/tmp/snapzy"
    )
  }

  func testExpandedUserPathUsesProvidedHomeDirectory() {
    let home = URL(fileURLWithPath: "/Users/example", isDirectory: true)

    XCTAssertEqual(
      KiteSnapConfigurationPaths.expandedUserPath("~/Desktop", homeDirectory: home),
      "/Users/example/Desktop"
    )
    XCTAssertEqual(
      KiteSnapConfigurationPaths.expandedUserPath("/tmp/snapzy", homeDirectory: home),
      "/tmp/snapzy"
    )
  }

  func testSuggestedConfigURLUsesAccountHomeDirectory() throws {
    guard
      let passwd = getpwuid(getuid()),
      let home = passwd.pointee.pw_dir
    else {
      throw XCTSkip("No POSIX home directory is available for the current user.")
    }

    let expectedHome = URL(fileURLWithPath: String(cString: home), isDirectory: true)
    let expectedURL = KiteSnapConfigurationPaths.suggestedConfigURL(homeDirectory: expectedHome)

    XCTAssertEqual(KiteSnapConfigurationService.shared.suggestedConfigURL.path, expectedURL.path)
  }
}
