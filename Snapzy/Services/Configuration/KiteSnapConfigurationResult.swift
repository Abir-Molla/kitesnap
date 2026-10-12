//
//  KiteSnapConfigurationResult.swift
//  Snapzy
//
//  Import/export result models for TOML configuration.
//

import Foundation

enum KiteSnapConfigurationIssueSeverity: Sendable {
  case warning
  case error
}

struct KiteSnapConfigurationIssue: Identifiable, Sendable {
  let id = UUID()
  let severity: KiteSnapConfigurationIssueSeverity
  let message: String
}

struct KiteSnapConfigurationImportResult: Sendable {
  let appliedChangeCount: Int
  let issues: [KiteSnapConfigurationIssue]

  var hasErrors: Bool {
    issues.contains { $0.severity == .error }
  }
}

enum KiteSnapConfigurationSyncDecision: Equatable, Sendable {
  case alreadyCurrent
  case syncAutomatically
  case askBeforeReplacing
}

enum KiteSnapConfigurationSyncStatus: Equatable, Sendable {
  case alreadyCurrent
  case synced
  case needsConfirmation
  case permissionRequired
}

struct KiteSnapConfigurationSyncResult: Sendable {
  let status: KiteSnapConfigurationSyncStatus
  let fileURL: URL
  let observedFileSignature: String?
  let exportedSettingsSignature: String?

  nonisolated init(
    status: KiteSnapConfigurationSyncStatus,
    fileURL: URL,
    observedFileSignature: String? = nil,
    exportedSettingsSignature: String? = nil
  ) {
    self.status = status
    self.fileURL = fileURL
    self.observedFileSignature = observedFileSignature
    self.exportedSettingsSignature = exportedSettingsSignature
  }
}

enum KiteSnapConfigurationSyncError: LocalizedError, Sendable {
  case fileChangedSinceConfirmation

  var errorDescription: String? {
    switch self {
    case .fileChangedSinceConfirmation:
      return "config.toml changed. Review it and try again."
    }
  }
}
