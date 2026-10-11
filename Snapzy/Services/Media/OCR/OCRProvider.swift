//
//  OCRProvider.swift
//  Snapzy
//
//  Pluggable OCR engine seam used by OCRService routing.
//

/// An OCR engine capable of recognizing text for an `OCRRequest`.
///
/// Implemented by `VisionOCRProvider` (built-in Apple Vision).
/// Sendability/isolation is left to each implementation — `VisionOCRProvider` is `@MainActor` like `OCRService`.
protocol OCRProvider {
  /// Engine identity stamped on produced `OCRResult`s.
  var engine: OCREngine { get }

  func recognize(_ request: OCRRequest) async throws -> OCRResult
}
