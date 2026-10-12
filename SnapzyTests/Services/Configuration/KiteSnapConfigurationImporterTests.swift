//
//  KiteSnapConfigurationImporterTests.swift
//  KiteSnapTests
//
//  Unit tests for TOML configuration import validation and application.
//

import XCTest
@testable import Snapzy

@MainActor
final class KiteSnapConfigurationImporterTests: XCTestCase {
  func testImportingDefaultDocumentResetsDelayedCaptureCountdown() {
    let defaults = UserDefaultsFactory.make()
    defaults.set(10, forKey: PreferencesKeys.screenshotDelayedCaptureSeconds)

    let source = KiteSnapConfigurationDefaultDocument.toml()
    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(defaults.integer(forKey: PreferencesKeys.screenshotDelayedCaptureSeconds), 3)
  }

  func testImportAppliesCaptureAndRecordingSettingsToProvidedDefaults() {
    let defaults = UserDefaultsFactory.make()
    let source = """
    schema_version = 1

    [capture.screenshot]
    format = "webp"
    show_cursor = true

    [recording]
    fps = 60
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertGreaterThanOrEqual(result.appliedChangeCount, 3)
    XCTAssertEqual(defaults.string(forKey: PreferencesKeys.screenshotFormat), "webp")
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.screenshotShowCursor) as? Bool, true)
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.recordingFPS) as? Int, 60)
  }

  func testImportAppliesRecordingMaxResolution() {
    let defaults = UserDefaultsFactory.make()
    let source = """
    schema_version = 1

    [recording]
    max_resolution = "fhd1080"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(defaults.string(forKey: PreferencesKeys.recordingMaxResolution), "fhd1080")
  }

  func testImportRejectsInvalidRecordingMaxResolution() {
    let defaults = UserDefaultsFactory.make()
    let source = """
    schema_version = 1

    [recording]
    max_resolution = "8k"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertTrue(result.hasErrors)
    XCTAssertNil(defaults.string(forKey: PreferencesKeys.recordingMaxResolution))
  }

  func testImportRejectsUnsupportedSchemaBeforeMutatingDefaults() {
    let defaults = UserDefaultsFactory.make()
    defaults.set("png", forKey: PreferencesKeys.screenshotFormat)
    let source = """
    schema_version = 99

    [capture.screenshot]
    format = "webp"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertTrue(result.hasErrors)
    XCTAssertEqual(result.appliedChangeCount, 0)
    XCTAssertEqual(defaults.string(forKey: PreferencesKeys.screenshotFormat), "png")
  }

  func testImportRejectsInvalidEnumsBeforeApplyingAnyMutation() {
    let defaults = UserDefaultsFactory.make()
    defaults.set("png", forKey: PreferencesKeys.screenshotFormat)
    let source = """
    schema_version = 1

    [capture.screenshot]
    format = "bmp"
    show_cursor = true
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertTrue(result.hasErrors)
    XCTAssertEqual(result.appliedChangeCount, 0)
    XCTAssertEqual(defaults.string(forKey: PreferencesKeys.screenshotFormat), "png")
    XCTAssertNil(defaults.object(forKey: PreferencesKeys.screenshotShowCursor))
  }

  func testImportRejectsUnknownShortcutModifiers() {
    let defaults = UserDefaultsFactory.make()
    let source = """
    schema_version = 1

    [shortcuts.global.fullscreen]
    key = "3"
    modifiers = ["command", "hyper"]
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertTrue(result.hasErrors)
    XCTAssertEqual(result.appliedChangeCount, 0)
  }

  func testImportExpandsTildePathsAgainstUserHomeDirectory() {
    let defaults = UserDefaultsFactory.make()
    let source = """
    schema_version = 1

    [general]
    export_location = "~/Desktop"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertTrue(result.issues.isEmpty)
    XCTAssertEqual(
      defaults.string(forKey: PreferencesKeys.exportLocation),
      KiteSnapConfigurationPaths.expandedUserPath("~/Desktop")
    )
  }

  func testImportAppliesQuickAccessTwoFingerSwipeSetting() {
    let defaults = UserDefaultsFactory.make()
    let manager = QuickAccessManager.shared
    let original = manager.twoFingerSwipeToDismissEnabled
    manager.twoFingerSwipeToDismissEnabled = true
    defer { manager.twoFingerSwipeToDismissEnabled = original }
    let source = """
    schema_version = 1

    [quick_access]
    two_finger_swipe_to_dismiss = false
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertFalse(manager.twoFingerSwipeToDismissEnabled)
  }

  func testImportWithoutAnnotateShortcutSectionDoesNotResetActionEnablement() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    let original = manager.isActionShortcutEnabled(for: .copyAndClose)
    manager.setActionShortcutEnabled(false, for: .copyAndClose)
    defer { manager.setActionShortcutEnabled(original, for: .copyAndClose) }

    let source = """
    schema_version = 1

    [capture.screenshot]
    show_cursor = true
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertFalse(manager.isActionShortcutEnabled(for: .copyAndClose))
  }

  func testImportAnnotateToolAcceptsNumericShortcut() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_tools]
    rectangle = "1"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(manager.shortcut(for: .rectangle), "1")
  }

  func testImportAnnotateToolNormalizesUppercaseShortcut() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_tools]
    rectangle = "R"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(manager.shortcut(for: .rectangle), "r")
    XCTAssertEqual(manager.tool(for: "r"), .rectangle)
  }

  func testImportAnnotateToolAcceptsSpecialCharacterShortcut() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_tools]
    rectangle = "="
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(manager.shortcut(for: .rectangle), "=")
  }

  func testImportAnnotateToolAllowsEmptyShortcut() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    manager.setShortcut("9", for: .rectangle)
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_tools]
    rectangle = ""
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertNil(manager.shortcut(for: .rectangle))
  }

  func testImportAnnotateToolRejectsMultiCharacterShortcut() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    manager.setShortcut("9", for: .rectangle)
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_tools]
    rectangle = "12"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertTrue(result.hasErrors)
    XCTAssertEqual(result.appliedChangeCount, 0)
    XCTAssertEqual(manager.shortcut(for: .rectangle), "9")
  }

  func testImportAnnotateActionAllowsEmptyShortcutWhileEnabled() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_actions.auto_redact_sensitive_data]
    enabled = true
    key = ""
    modifiers = []
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertNil(manager.shortcut(for: .autoRedactSensitiveData))
    XCTAssertTrue(manager.isActionShortcutEnabled(for: .autoRedactSensitiveData))
  }

  func testImportAnnotateActionAppliesAutoRedactShortcut() {
    let defaults = UserDefaultsFactory.make()
    let manager = AnnotateShortcutManager.shared
    manager.resetToDefaults()
    defer { manager.resetToDefaults() }

    let source = """
    schema_version = 1

    [shortcuts.annotate_actions.auto_redact_sensitive_data]
    enabled = true
    key = "r"
    modifiers = ["command", "shift"]
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertNotNil(manager.shortcut(for: .autoRedactSensitiveData))
    XCTAssertTrue(manager.isActionShortcutEnabled(for: .autoRedactSensitiveData))
  }

  func testImportAppliesNewConfigurationFields() {
    let defaults = UserDefaultsFactory.make()
    let manager = QuickAccessManager.shared
    
    let originalHide = manager.hideCardWhenWindowOpen
    let originalStyle = manager.animationStyle
    let originalLeftAction = QuickAccessSwipeActionStore.shared.swipeLeftAction
    let originalRightAction = QuickAccessSwipeActionStore.shared.swipeRightAction
    let originalTrackpadMode = QuickAccessTrackpadSwipeModeStore.shared.mode
    let pinZoomModeStore = QuickAccessPinZoomModeStore.shared
    let originalPinZoomMode = pinZoomModeStore.mode
    
    defer {
      manager.hideCardWhenWindowOpen = originalHide
      manager.animationStyle = originalStyle
      QuickAccessSwipeActionStore.shared.setAction(.left, action: originalLeftAction)
      QuickAccessSwipeActionStore.shared.setAction(.right, action: originalRightAction)
      QuickAccessTrackpadSwipeModeStore.shared.setMode(originalTrackpadMode)
      pinZoomModeStore.setMode(originalPinZoomMode)
      QuickAccessPinWindowManager.shared.setPinZoomMode(originalPinZoomMode)
    }

    let source = """
    schema_version = 1

    [general]
    show_menu_bar_icon = false

    [capture.screenshot]
    freeze_area = true
    delayed_capture_seconds = 5
    show_selection_area_overlay = false
    reverse_magnifier_zoom_direction = true
    show_magnifier_by_default = true

    [annotate]
    combine_save_as_edit = false
    default_tool = "arrow"
    remember_last_tool = true

    [quick_access]
    play_sounds = false
    trackpad_swipe_mode = "natural"
    pin_zoom_mode = "windowFollowsImage"
    swipe_left_action = "pinToScreen"
    swipe_right_action = "none"
    hide_card_when_window_open = false
    animation_style = "scale"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    
    // general
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.showMenuBarIcon) as? Bool, false)
    
    // capture.screenshot
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.screenshotFreezeArea) as? Bool, true)
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.screenshotDelayedCaptureSeconds) as? Int, 5)
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.screenshotShowSelectionAreaOverlay) as? Bool, false)
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.screenshotReverseMagnifierZoomDirection) as? Bool, true)
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.screenshotShowMagnifierByDefault) as? Bool, true)
    
    // annotate
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.annotateCombineSaveAsEdit) as? Bool, false)
    XCTAssertEqual(defaults.string(forKey: PreferencesKeys.annotateDefaultTool), "arrow")
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.annotateRememberLastTool) as? Bool, true)
    
    // quick access
    XCTAssertEqual(defaults.object(forKey: PreferencesKeys.quickAccessPlaySounds) as? Bool, false)
    XCTAssertEqual(QuickAccessTrackpadSwipeModeStore.shared.mode, .natural)
    XCTAssertEqual(pinZoomModeStore.mode, .windowFollowsImage)
    XCTAssertEqual(QuickAccessSwipeActionStore.shared.swipeLeftAction, .pinToScreen)
    XCTAssertNil(QuickAccessSwipeActionStore.shared.swipeRightAction)
    XCTAssertFalse(manager.hideCardWhenWindowOpen)
    XCTAssertEqual(manager.animationStyle, .scale)
  }

  func testImportRejectsInvalidEnumValues() {
    let defaults = UserDefaultsFactory.make()
    
    let sourceInvalidTrackpad = """
    schema_version = 1
    [quick_access]
    trackpad_swipe_mode = "invalid_mode"
    """
    let result1 = KiteSnapConfigurationImporter.importTOML(sourceInvalidTrackpad, defaults: defaults)
    XCTAssertTrue(result1.hasErrors)

    let sourceInvalidPinZoomMode = """
    schema_version = 1
    [quick_access]
    pin_zoom_mode = "invalid_mode"
    """
    let resultPinZoomMode = KiteSnapConfigurationImporter.importTOML(sourceInvalidPinZoomMode, defaults: defaults)
    XCTAssertTrue(resultPinZoomMode.hasErrors)

    let sourceInvalidLeftAction = """
    schema_version = 1
    [quick_access]
    swipe_left_action = "invalid_action"
    """
    let result2 = KiteSnapConfigurationImporter.importTOML(sourceInvalidLeftAction, defaults: defaults)
    XCTAssertTrue(result2.hasErrors)

    let sourceInvalidAnim = """
    schema_version = 1
    [quick_access]
    animation_style = "invalid_style"
    """
    let result3 = KiteSnapConfigurationImporter.importTOML(sourceInvalidAnim, defaults: defaults)
    XCTAssertTrue(result3.hasErrors)
  }

  func testImportAppliesMenuBarCustomization() {
    let defaults = UserDefaultsFactory.make()
    let store = MenuBarCustomizationStore.shared
    let originalOrder = store.itemOrder
    let originalHidden = store.hiddenItems
    let originalStyle = store.iconStyle
    defer {
      store.applyConfiguration(
        order: originalOrder,
        hiddenItems: originalHidden,
        iconStyle: originalStyle
      )
    }
    let source = """
    schema_version = 1

    [menu_bar]
    icon_style = "cameraFill"
    item_order = ["shortcutList", "captureOCR"]
    hidden_items = ["openHistory"]
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(store.iconStyle, .cameraFill)
    XCTAssertEqual(store.orderedItems(for: .tools).first, .shortcutList)
    XCTAssertEqual(store.orderedItems(for: .capture).first, .captureOCR)
    XCTAssertTrue(store.isHidden(.openHistory))
  }

  func testImportRejectsInvalidMenuBarIconStyle() {
    let defaults = UserDefaultsFactory.make()
    let store = MenuBarCustomizationStore.shared
    let originalStyle = store.iconStyle
    defer { store.setIconStyle(originalStyle) }
    let source = """
    schema_version = 1

    [menu_bar]
    icon_style = "invalid_style"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertTrue(result.hasErrors)
    XCTAssertEqual(store.iconStyle, originalStyle)
  }

  // MARK: - OCR Configuration

  func testImportSilentlyIgnoresCustomOCRModelsAndSelectedModel() throws {
    let defaults = UserDefaultsFactory.make()
    let id = UUID().uuidString
    let source = """
    schema_version = 1

    [capture.ocr]
    success_notification = true
    selected_model = "custom:\(id)"
    custom_models = "[{\\\"id\\\":\\\"\(id)\\\",\\\"name\\\":\\\"My API\\\",\\\"baseURL\\\":\\\"https://api.example.com\\\",\\\"modelIdentifier\\\":\\\"test-model\\\",\\\"hasAPIKey\\\":true}]"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)

    XCTAssertFalse(result.hasErrors)
    XCTAssertEqual(defaults.bool(forKey: PreferencesKeys.ocrSuccessNotificationEnabled), true)
  }

  func testImportSilentlyIgnoresMalformedCustomOCRModels() {
    let defaults = UserDefaultsFactory.make()
    let source = """
    schema_version = 1

    [capture.ocr]
    custom_models = "not json"
    """

    let result = KiteSnapConfigurationImporter.importTOML(source, defaults: defaults)
    XCTAssertFalse(result.hasErrors)
  }

  func testExportOmitsCustomOCRModelsAndSelectedModel() throws {
    let defaults = UserDefaultsFactory.make()

    let source = KiteSnapConfigurationExporter.exportTOML(defaults: defaults)
    let document = try SimpleTOMLParser.parse(source)

    XCTAssertNil(document.value(at: "capture", "ocr", "custom_models"))
    XCTAssertNil(document.value(at: "capture", "ocr", "selected_model"))
    XCTAssertNil(document.value(at: "capture", "ocr", "catalog_models"))
  }

}
