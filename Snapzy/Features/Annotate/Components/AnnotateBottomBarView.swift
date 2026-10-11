//
//  AnnotateBottomBarView.swift
//  Snapzy
//
//  Bottom bar with zoom, drag handle, and action buttons
//

import SwiftUI

private enum AnnotateBottomActionRegistration: Equatable {
  case annotateDefault
  case crop
}

private enum AnnotateBottomBarMeasuredSide: Hashable {
  case left
  case right
}

private struct AnnotateBottomBarWidthPreferenceKey: PreferenceKey {
  static let defaultValue: [AnnotateBottomBarMeasuredSide: CGFloat] = [:]

  static func reduce(
    value: inout [AnnotateBottomBarMeasuredSide: CGFloat],
    nextValue: () -> [AnnotateBottomBarMeasuredSide: CGFloat]
  ) {
    value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
  }
}

private extension View {
  func measuredBottomBarWidth(_ side: AnnotateBottomBarMeasuredSide) -> some View {
    background(
      GeometryReader { geometry in
        Color.clear.preference(
          key: AnnotateBottomBarWidthPreferenceKey.self,
          value: [side: geometry.size.width]
        )
      }
    )
  }
}

/// Bottom bar containing zoom controls and action buttons
struct AnnotateBottomBarView: View {
  @ObservedObject var state: AnnotateState
  let eventRouter: AnnotateWindowEventRouter
  @ObservedObject private var preferencesManager = PreferencesManager.shared
  @ObservedObject private var annotateShortcutManager = AnnotateShortcutManager.shared

  @State private var measuredLeftWidth: CGFloat = 0
  @State private var measuredRightWidth: CGFloat = 0
  @State private var isZoomHovered = false
  @Environment(\.liquidGlassRenderMode) private var liquidGlassRenderMode
  @AppStorage(PreferencesKeys.useLiquidGlass) private var isLiquidGlassEnabled = true

  private let centeredDragFullWidth: CGFloat = 160
  private let centeredDragCompactWidth: CGFloat = 44
  private let centeredDragHeight: CGFloat = 32
  private let centeredDragSideGap: CGFloat = 12

  private var usesNativeGlass: Bool {
    LiquidGlassCapabilities.usesNativeGlass(
      for: liquidGlassRenderMode,
      userEnabled: isLiquidGlassEnabled
    )
  }

  var body: some View {
    VStack(spacing: 0) {
      // Mockup preset bar (shown when mockup mode is active)
      if state.editorMode == .mockup {
        MockupPresetBarInline(state: state)
        Divider()
      }

      bottomBarContent
      .windowBottomBarPadding()
      .animation(.easeInOut(duration: 0.16), value: activeActionRegistration)
      .onPreferenceChange(AnnotateBottomBarWidthPreferenceKey.self) { widths in
        measuredLeftWidth = widths[.left] ?? 0
        measuredRightWidth = widths[.right] ?? 0
      }

    }
  }

  // MARK: - Left Section

  private var bottomBarContent: some View {
    GeometryReader { geometry in
      let dragWidth = centeredDragWidth(for: geometry.size.width)

      ZStack {
        HStack(spacing: 0) {
          // Left section: zoom + mode toggle
          leftSection
            .fixedSize(horizontal: true, vertical: false)
            .measuredBottomBarWidth(.left)

          Spacer(minLength: 0)

          // Right section: registered action surface
          registeredActionSurface
            .fixedSize(horizontal: true, vertical: false)
            .measuredBottomBarWidth(.right)
        }

        // Center: Drag handle pinned to true bar center. If the bar gets too
        // tight, it compacts before hiding so side controls stay clickable.
        if state.hasImage && activeActionRegistration == .annotateDefault && dragWidth > 0 {
          dragHandle(
            width: dragWidth,
            isCompact: dragWidth < centeredDragFullWidth
          )
          .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
      }
    }
    .frame(height: centeredDragHeight)
  }

  private var leftSection: some View {
    HStack(spacing: 10) {
      zoomPicker
      modeToggle
    }
  }

  private func centeredDragWidth(for contentWidth: CGFloat) -> CGFloat {
    guard contentWidth > 0 else { return centeredDragFullWidth }

    let halfWidth = contentWidth / 2
    let leftClearance = halfWidth - measuredLeftWidth - centeredDragSideGap
    let rightClearance = halfWidth - measuredRightWidth - centeredDragSideGap
    let availableCenteredWidth = max(0, min(leftClearance, rightClearance) * 2)

    if availableCenteredWidth >= centeredDragFullWidth {
      return centeredDragFullWidth
    }

    if availableCenteredWidth >= centeredDragCompactWidth {
      return centeredDragCompactWidth
    }

    return 0
  }

  // MARK: - Zoom Picker

  private var zoomShape: Capsule {
    Capsule(style: .continuous)
  }

  private var zoomPicker: some View {
    Menu {
      ForEach(state.zoomMenuPresetPercents, id: \.self) { percent in
        Button("\(percent)%") {
          withAnimation(.easeOut(duration: 0.15)) {
            state.zoomLevel = state.zoomLevel(forDisplayedPercent: percent)
          }
        }
      }

      Divider()

      Button("1:1") {
        withAnimation(.easeOut(duration: 0.15)) {
          state.zoomLevel = state.actualPixelZoomLevel
        }
      }

      Button(L10n.AnnotateUI.fitWithShortcut("⌘0")) {
        withAnimation(.easeOut(duration: 0.15)) {
          state.zoomLevel = 1.0
        }
      }
    } label: {
      HStack(spacing: 4) {
        Text("\(state.currentDisplayedZoomPercent)%")
          .font(.system(size: 11.5, weight: .medium))
        Image(systemName: "chevron.down")
          .font(.system(size: 8, weight: .semibold))
      }
      .foregroundStyle(isZoomHovered ? LiquidGlassTokens.inkPrimary : LiquidGlassTokens.inkBody)
      .padding(.horizontal, 10)
      .frame(height: ControlMetrics.bottomBarControl)
      .contentShape(zoomShape)
      .liquidGlassSurface(
        shape: zoomShape,
        substrate: isZoomHovered
          ? LiquidGlassTokens.controlSubstrateHover
          : LiquidGlassTokens.controlSubstrateResting,
        tint: isZoomHovered ? 0.06 : 0.01,
        highlight: .none,
        withRimLighting: !usesNativeGlass,
        isInteractive: true,
        glassTint: nil
      )
      .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
      .onHover { hovering in
        withAnimation(LiquidGlassTokens.hoverSpring) {
          isZoomHovered = hovering
        }
      }
      .animation(LiquidGlassTokens.hoverSpring, value: isZoomHovered)
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .fixedSize(horizontal: true, vertical: false)
  }

  // MARK: - Mode Toggle

  /// Check if any mockup transforms have been applied
  private var hasMockupTransforms: Bool {
    state.mockupRotationX != 0 ||
    state.mockupRotationY != 0 ||
    state.mockupRotationZ != 0
  }

  private var modeToggle: some View {
    LiquidGlassSegmentedControl(
      items: AnnotateState.EditorMode.allCases,
      selection: $state.editorMode,
      activeGlassTint: nil,
      controlHeight: ControlMetrics.bottomBarControl
    ) { mode in
      HStack(spacing: 5) {
        Image(systemName: modeIcon(for: mode))
          .font(.system(size: 11, weight: .medium))
        Text(modeTitle(for: mode))
          .lineLimit(1)
      }
      .help(modeTitle(for: mode))
    }
  }

  private func modeIcon(for mode: AnnotateState.EditorMode) -> String {
    switch mode {
    case .annotate:
      return "pencil.and.outline"
    case .mockup:
      return "cube.transparent"
    case .preview:
      return "eye"
    }
  }

  private func modeTitle(for mode: AnnotateState.EditorMode) -> String {
    switch mode {
    case .annotate:
      return L10n.AnnotateUI.modeAnnotate
    case .mockup:
      return L10n.AnnotateUI.modeMockup
    case .preview:
      return L10n.AnnotateUI.modePreview
    }
  }

  // MARK: - Drag Handle (Liquid Glass)

  @State private var isDragHovering = false

  private func dragHandle(width: CGFloat, isCompact: Bool) -> some View {
    let dragState = state.dragToAppPreparationState
    let isPreparing = dragState == .preparing
    let isReady = dragState == .ready
    let isLit = isPreparing || (isReady && isDragHovering)

    return AnnotateDragHandleView(state: state)
      .frame(width: width, height: centeredDragHeight)
      .overlay {
        HStack(spacing: isCompact ? 8 : 7) {
          if isPreparing {
            ProgressView()
              .controlSize(.small)
              .scaleEffect(0.7)
          } else if isCompact {
            dragGrip
          } else {
            dragGrip

            Text(L10n.AnnotateUI.dragToApp)
              .font(.system(size: 12, weight: .medium))

            dragGrip
          }
        }
        .foregroundColor(dragInk(for: dragState))
        .allowsHitTesting(false)
      }
      .liquidGlassChrome(
        shape: Capsule(style: .continuous),
        isVisible: true,
        isActive: isLit
      )
      // Rule 2: scale, not opacity — a transform never detaches the glass backdrop.
      .scaleEffect(isLit ? 1.02 : 1)
      .onHover { hovering in
        withAnimation(LiquidGlassTokens.hoverSpring) {
          isDragHovering = hovering
        }
      }
      .animation(LiquidGlassTokens.hoverSpring, value: dragState)
      .animation(LiquidGlassTokens.hoverSpring, value: isDragHovering)
      .help(L10n.AnnotateUI.dragToAppHelp)
  }

  private var dragGrip: some View {
    VStack(spacing: 3) {
      ForEach(0..<3, id: \.self) { _ in
        Capsule(style: .continuous)
          .fill(LiquidGlassTokens.inkBody.opacity(0.5))
          .frame(width: 7, height: 1.3)
      }
    }
    .frame(width: 10)
  }

  private func dragInk(for state: AnnotateState.DragToAppPreparationState) -> Color {
    switch state {
    case .ready:
      return isDragHovering ? LiquidGlassTokens.inkPrimary : LiquidGlassTokens.inkBody
    case .preparing:
      return LiquidGlassTokens.inkPrimary
    case .unavailable:
      return LiquidGlassTokens.inkFaint
    }
  }

  // MARK: - Action Buttons

  private var activeActionRegistration: AnnotateBottomActionRegistration {
    // Specialized tools can register a replacement for the default Annotate actions here.
    if state.selectedTool == .crop && state.isCropActive {
      return .crop
    }

    return .annotateDefault
  }

  @ViewBuilder
  private var registeredActionSurface: some View {
    switch activeActionRegistration {
    case .annotateDefault:
      annotateActionButtons
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    case .crop:
      CropToolbarView(state: state)
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }
  }

  private var annotateActionButtons: some View {
    let togglePinShortcut = annotateShortcutManager.isActionShortcutEnabled(for: .togglePin)
      ? annotateShortcutManager.togglePinShortcut?.displayString : nil
    let copyAndCloseShortcut = annotateShortcutManager.isActionShortcutEnabled(for: .copyAndClose)
      ? annotateShortcutManager.copyAndCloseShortcut?.displayString : nil

    return HStack(spacing: 12) {
      BottomBarButton(
        icon: "plus.rectangle.on.rectangle",
        tooltip: L10n.AnnotateUI.newWindow
      ) {
        AnnotateManager.shared.openEmptyAnnotation()
      }

      BottomBarButton(icon: "square.and.arrow.up", tooltip: L10n.Common.share) {
        share()
      }

      BottomBarButton(
        icon: state.isPinned ? "pin.fill" : "pin",
        tooltip: tooltipText(
          state.isPinned ? L10n.AnnotateUI.unpinWindow : L10n.AnnotateUI.pinWindow,
          shortcut: togglePinShortcut
        )
      ) {
        pin()
      }

      BottomBarButton(
        icon: "doc.on.doc",
        tooltip: tooltipText(L10n.AnnotateUI.copyToClipboard, shortcut: copyAndCloseShortcut)
      ) {
        copyToClipboard()
      }

      BottomBarButton(icon: "trash", tooltip: L10n.Common.deleteAction) {
        confirmAndDeleteImage()
      }
      .disabled(state.sourceURL == nil)
    }
    // One effect container for the whole row: the glass is evaluated in a single pass instead of
    // once per button, and neighbours merge when they light up together.
    .liquidGlassGroup(spacing: Spacing.xs)
  }

  private func tooltipText(_ title: String, shortcut: String?) -> String {
    guard let shortcut else { return title }
    return L10n.Common.withShortcut(title, shortcut)
  }

  // MARK: - Actions

  private func share() {
    guard let window = NSApp.keyWindow, let contentView = window.contentView else { return }
    AnnotateExporter.share(state: state, from: contentView)
  }

  private func pin() {
    if let window = NSApp.keyWindow {
      let newPinned = !state.isPinned
      if let annotateWindow = window as? AnnotateWindow {
        annotateWindow.setRestingLevel(newPinned ? .floating : .normal)
      } else {
        window.level = newPinned ? .floating : .normal
      }
      state.isPinned = newPinned
    }
  }

  private func copyToClipboard() {
    guard let window = NSApp.keyWindow else { return }
    // Post notification so the controller handles save + cache + copy
    NotificationCenter.default.post(name: .annotateCopyAndClose, object: window)
  }

  private func confirmAndDeleteImage() {
    guard let sourceURL = state.sourceURL,
          let window = NSApp.keyWindow else { return }

    let alert = NSAlert()
    alert.messageText = L10n.AnnotateUI.deleteScreenshotTitle
    alert.informativeText = L10n.AnnotateUI.deleteScreenshotMessage(sourceURL.lastPathComponent)
    alert.alertStyle = .warning
    alert.addButton(withTitle: L10n.Common.deleteAction)
    alert.addButton(withTitle: L10n.Common.cancel)

    alert.beginSheetModal(for: window) { [state] response in
      guard response == .alertFirstButtonReturn else { return }

      // Clear matching history record FIRST so the user does not see a stale
      // "file missing" entry after the underlying file is trashed.
      CaptureHistoryStore.shared.removeByFilePath(sourceURL.path)
      AnnotationSessionStore.shared.deleteSession(for: sourceURL)

      // Remove QuickAccess card if it exists
      if let itemId = state.quickAccessItemId {
        QuickAccessManager.shared.removeItem(id: itemId)
      }

      // Trash the file
      let fileAccessManager = SandboxFileAccessManager.shared
      let fileAccess = fileAccessManager.beginAccessingURL(sourceURL)
      let directoryAccess = fileAccessManager.beginAccessingURL(sourceURL.deletingLastPathComponent())
      defer {
        fileAccess.stop()
        directoryAccess.stop()
      }

      try? FileManager.default.trashItem(at: sourceURL, resultingItemURL: nil)

      // Close the annotate window (captured before alert)
      state.hasUnsavedChanges = false
      window.close()
    }
  }

}
