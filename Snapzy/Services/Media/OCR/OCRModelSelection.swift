//
//  OCRModelSelection.swift
//  Snapzy
//
//  Persisted OCR model selection with stable string encoding.
//

import Foundation

/// Which OCR provider the user selected in Settings.
enum OCRModelSelection: String, Equatable, Codable {
  /// Apple Vision OCR bundled with macOS — always available, and the single engine in KiteSnap.
  case builtIn = "builtin"

  var persistedValue: String {
    rawValue
  }

  /// Unknown, custom/remote, or corrupt values map to `.builtIn` so any old
  /// stored value safely falls back without error.
  init(persistedValue: String) {
    self = .builtIn
  }

  init(from decoder: Decoder) throws {
    if let container = try? decoder.singleValueContainer(),
       let _ = try? container.decode(String.self) {
      self = .builtIn
    } else {
      self = .builtIn
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
