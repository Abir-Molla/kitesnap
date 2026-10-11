//
//  OCRModelResolver.swift
//  Snapzy
//
//  Resolves the persisted OCR model selection to a provider, with fallback.
//

import Foundation

/// Result of resolving a selection: the effective selection (always `.builtIn`)
/// plus the provider that runs on-device recognition.
struct OCRModelResolution {
  let selection: OCRModelSelection
  let provider: OCRProvider
}

/// Routes OCR requests to the Apple Vision provider.
@MainActor
struct OCRModelResolver {
  init(defaults: UserDefaults = .standard) {}

  func storedSelection() -> OCRModelSelection {
    .builtIn
  }

  func resolveStoredSelection() -> OCRModelResolution {
    resolve(.builtIn)
  }

  func resolve(_ selection: OCRModelSelection) -> OCRModelResolution {
    OCRModelResolution(selection: .builtIn, provider: VisionOCRProvider())
  }
}
