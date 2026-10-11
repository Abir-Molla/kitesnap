//
//  LiquidGlassPreview.swift
//  Snapzy
//
//  Interactive Design System Studio & Playground for Liquid Glass:
//  macOS 26+ (Apple Native Liquid Glass) vs macOS 13–15 (Solid Native Fallback).
//

import AppKit
import SwiftUI

// MARK: - Wallpapers

enum PlaygroundWallpaper: String, CaseIterable, Identifiable {
  case darkAmbient = "dark"
  case brightDesktop = "bright"
  case vibrantSunset = "vibrant"
  case emeraldOcean = "ocean"
  case checkerboard = "checker"

  var id: String { rawValue }

  var title: String {
    switch self {
    case .darkAmbient: return "Dark Ambient"
    case .brightDesktop: return "Bright Clean"
    case .vibrantSunset: return "Sunset Gradient"
    case .emeraldOcean: return "Emerald Ocean"
    case .checkerboard: return "Checkerboard"
    }
  }

  @ViewBuilder
  var backgroundView: some View {
    switch self {
    case .darkAmbient:
      LinearGradient(
        colors: [Color(red: 0.09, green: 0.11, blue: 0.16), Color(red: 0.04, green: 0.05, blue: 0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    case .brightDesktop:
      LinearGradient(
        colors: [Color(red: 0.96, green: 0.97, blue: 0.99), Color(red: 0.88, green: 0.91, blue: 0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    case .vibrantSunset:
      LinearGradient(
        colors: [Color(red: 0.38, green: 0.16, blue: 0.58), Color(red: 0.85, green: 0.32, blue: 0.38), Color(red: 0.96, green: 0.58, blue: 0.28)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    case .emeraldOcean:
      LinearGradient(
        colors: [Color(red: 0.08, green: 0.35, blue: 0.42), Color(red: 0.05, green: 0.22, blue: 0.32), Color(red: 0.03, green: 0.12, blue: 0.20)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    case .checkerboard:
      CheckerboardCanvas()
    }
  }
}

// MARK: - Checkerboard Pattern

private struct CheckerboardCanvas: View {
  var body: some View {
    Canvas { context, size in
      let squareSize: CGFloat = 20
      let rows = Int(ceil(size.height / squareSize))
      let cols = Int(ceil(size.width / squareSize))

      for row in 0..<rows {
        for col in 0..<cols {
          let isDark = (row + col).isMultiple(of: 2)
          let color = isDark ? Color(white: 0.18) : Color(white: 0.26)
          let rect = CGRect(
            x: CGFloat(col) * squareSize,
            y: CGFloat(row) * squareSize,
            width: squareSize,
            height: squareSize
          )
          context.fill(Path(rect), with: .color(color))
        }
      }
    }
  }
}

// MARK: - Display Mode

enum PlaygroundDisplayMode: String, CaseIterable, Identifiable {
  case sideBySide = "sideBySide"
  case macOS26 = "macos26"
  case macOS1315 = "macos1315"

  var id: String { rawValue }

  var title: String {
    switch self {
    case .sideBySide: return "Side-by-Side"
    case .macOS26: return "macOS 26+ (Apple Glass)"
    case .macOS1315: return "macOS 13–15 (Solid Native)"
    }
  }
}

// MARK: - Design System Categories

enum PlaygroundCategory: String, CaseIterable, Identifiable {
  case overview = "overview"
  case buttons = "buttons"
  case segmented = "segmented"
  case toolbars = "toolbars"
  case cards = "cards"
  case forms = "forms"
  case mockups = "mockups"

  var id: String { rawValue }

  var title: String {
    switch self {
    case .overview: return "Overview & Tokens"
    case .buttons: return "Buttons & Actions"
    case .segmented: return "Segmented Controls"
    case .toolbars: return "Toolbars & Docks"
    case .cards: return "Cards & Overlays"
    case .forms: return "Form Controls"
    case .mockups: return "Feature Mockups"
    }
  }

  var icon: String {
    switch self {
    case .overview: return "swatchpalette"
    case .buttons: return "button.programmable"
    case .segmented: return "square.split.2x1"
    case .toolbars: return "menubar.rectangle"
    case .cards: return "macwindow.on.rectangle"
    case .forms: return "slider.horizontal.3"
    case .mockups: return "sparkles.rectangle.stack"
    }
  }

  var subtitle: String {
    switch self {
    case .overview: return "Colors, substrate opacity, radii, and specular borders"
    case .buttons: return "Complete emphasis, sizes, shapes, and interaction states"
    case .segmented: return "Smooth segmented controls with fluid glass cushioning"
    case .toolbars: return "Annotate floating toolbar and Recording control dock"
    case .cards: return "Quick Access cards, notification toasts, and confirmation dialogs"
    case .forms: return "Glass search fields, sliders, toggles, and controls"
    case .mockups: return "Realistic simulation of the app experience in production"
    }
  }
}

// MARK: - Reusable Studio Primitives

/// Draggable divider for resizing panes with hover highlight and resize cursor.
struct ResizeDivider: View {
  @Binding var width: CGFloat
  let minWidth: CGFloat
  let maxWidth: CGFloat
  let isRight: Bool

  @State private var isHovering = false
  @State private var startWidth: CGFloat = 0

  var body: some View {
    Rectangle()
      .fill(isHovering ? Color.accentColor.opacity(0.8) : Color.clear)
      .frame(width: 2)
      .background(
        Rectangle()
          .fill(Color.white.opacity(0.08))
          .frame(width: 1)
      )
      .contentShape(Rectangle().inset(by: -4))
      .onHover { hovering in
        isHovering = hovering
        if hovering {
          NSCursor.resizeLeftRight.push()
        } else {
          NSCursor.pop()
        }
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            if startWidth == 0 {
              startWidth = width
            }
            let delta = value.translation.width
            let newWidth = startWidth + (isRight ? -delta : delta)
            width = max(minWidth, min(maxWidth, newWidth))
          }
          .onEnded { _ in
            startWidth = 0
          }
      )
  }
}

/// Collapsible accordion section with smooth chevron rotation and optional reset action.
struct AccordionSection<Content: View>: View {
  let title: String
  @Binding var isExpanded: Bool
  var onReset: (() -> Void)? = nil
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button {
        withAnimation(.easeInOut(duration: 0.2)) {
          isExpanded.toggle()
        }
      } label: {
        HStack {
          Text(title)
            .font(.system(size: 11.5, weight: .bold))
            .foregroundColor(.primary)

          Spacer()

          if let onReset, isExpanded {
            Button {
              onReset()
            } label: {
              Text("Reset")
                .font(.system(size: 10))
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
          }

          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .foregroundColor(.secondary)
            .font(.system(size: 9.5, weight: .bold))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.clear)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if isExpanded {
        VStack(alignment: .leading, spacing: 10) {
          content()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
      }

      Divider()
        .overlay(Color.white.opacity(0.06))
    }
  }
}

/// Precision slider row with 80pt left label, slider, and monospaced readout (double-click to reset).
struct StudioSliderRow: View {
  let title: String
  @Binding var doubleValue: Double
  let range: ClosedRange<Double>
  let step: Double
  let defaultValue: Double

  init(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, defaultValue: Double) {
    self.title = title
    self._doubleValue = value
    self.range = range
    self.step = step
    self.defaultValue = defaultValue
  }

  init(title: String, cgFloatValue: Binding<CGFloat>, range: ClosedRange<Double>, step: Double, defaultValue: Double) {
    self.title = title
    self._doubleValue = Binding<Double>(
      get: { Double(cgFloatValue.wrappedValue) },
      set: { cgFloatValue.wrappedValue = CGFloat($0) }
    )
    self.range = range
    self.step = step
    self.defaultValue = defaultValue
  }

  var body: some View {
    HStack(spacing: 8) {
      Text(title)
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(.secondary)
        .frame(width: 82, alignment: .leading)

      let roundedBinding = Binding<Double>(
        get: { doubleValue },
        set: { newValue in
          let stepped = (newValue / step).rounded() * step
          doubleValue = min(max(stepped, range.lowerBound), range.upperBound)
        }
      )

      Slider(value: roundedBinding, in: range)
        .controlSize(.small)
        .tint(.accentColor)

      Text(String(format: "%.2f", doubleValue))
        .font(.system(size: 11, weight: .medium, design: .monospaced))
        .foregroundColor(.primary)
        .frame(width: 38, alignment: .trailing)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
          withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            doubleValue = defaultValue
          }
        }
        .help("Double-click value to reset to default (\(String(format: "%.2f", defaultValue)))")
    }
    .padding(.vertical, 2)
  }
}

// MARK: - Split View Observer

/// An AppKit bridge to detect whether the sidebar column of NSSplitView is collapsed.
struct SplitViewObserver: NSViewRepresentable {
  @Binding var isSidebarCollapsed: Bool

  class ObserverNSView: NSView {
    var onChange: ((Bool) -> Void)?

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      DiagnosticLogger.shared.log(.error, .ui, "OBSERVER: viewDidMoveToWindow window=\(String(describing: window))")
      check()
      if let window {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(didResize),
          name: NSWindow.didResizeNotification,
          object: window
        )
      }
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(didResize),
        name: NSSplitView.didResizeSubviewsNotification,
        object: nil
      )
    }

    @objc private func didResize() {
      check()
    }

    override func layout() {
      super.layout()
      check()
    }

    private func check() {
      guard window != nil else { return }
      let xInWindow = convert(CGPoint.zero, to: nil).x
      let collapsed = xInWindow < 50
      onChange?(collapsed)
    }
  }

  class Coordinator {
    var isSidebarCollapsed: Binding<Bool>

    init(isSidebarCollapsed: Binding<Bool>) {
      self.isSidebarCollapsed = isSidebarCollapsed
    }

    func update(collapsed: Bool) {
      if isSidebarCollapsed.wrappedValue != collapsed {
        DispatchQueue.main.async {
          withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            self.isSidebarCollapsed.wrappedValue = collapsed
          }
        }
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(isSidebarCollapsed: $isSidebarCollapsed)
  }

  func makeNSView(context: Context) -> ObserverNSView {
    let view = ObserverNSView()
    let coordinator = context.coordinator
    view.onChange = { collapsed in
      coordinator.update(collapsed: collapsed)
    }
    return view
  }

  func updateNSView(_ nsView: ObserverNSView, context: Context) {
    let coordinator = context.coordinator
    coordinator.isSidebarCollapsed = $isSidebarCollapsed
    nsView.onChange = { collapsed in
      coordinator.update(collapsed: collapsed)
    }
  }
}

// MARK: - Main Playground View

struct LiquidGlassPlaygroundView: View {
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var isSidebarCollapsed = false
  @State private var selectedCategory: PlaygroundCategory = .buttons
  @State private var hoveredCategory: PlaygroundCategory? = nil
  @State private var displayMode: PlaygroundDisplayMode = .sideBySide
  @State private var selectedWallpaper: PlaygroundWallpaper = .darkAmbient
  @State private var colorSchemeOverride: ColorScheme? = .dark
  @State private var isInspectorVisible = true
  @State private var inspectorWidth: CGFloat = 295

  // Accordion states
  @State private var expandGlobalSection = true
  @State private var expandSimulatorSection = true
  @State private var expandTuningSection = true
  @State private var expandLayersSection = false
  @State private var expandExportSection = false

  // Optical Tuning State
  @State private var tuning = LiquidGlassTuning.default
  @AppStorage(PreferencesKeys.useLiquidGlass) private var useLiquidGlass = true

  // Simulator State
  @State private var simulateDisabled = false
  @State private var simulateBusy = false
  @State private var hasCopiedCode = false
  @State private var toastMessage: String? = nil

  // Component Interactive States
  @State private var selectedTab = "Capture"
  @State private var selectedMode = 1
  @State private var isActionActive = false
  @State private var isToolbarToggleActive = true
  @State private var searchQuery = ""
  @State private var sliderValue: Double = 0.65
  @State private var toggleValue = true
  @State private var checkboxValue = true
  @State private var selectedColorIndex = 0

  private let tabs = ["Capture", "Record", "OCR", "History"]
  private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple]

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      studioSidebar
        .ignoresSafeArea(edges: .top)
        .navigationSplitViewColumnWidth(min: 210, ideal: 240, max: 300)
    } detail: {
      let effectiveSidebarCollapsed = isSidebarCollapsed || columnVisibility == .detailOnly
      let topBarLeadingPadding: CGFloat = effectiveSidebarCollapsed ? 168 : 36

      HStack(spacing: 0) {
        // 2. Central Studio Canvas
        ZStack(alignment: .top) {
          selectedWallpaper.backgroundView
            .ignoresSafeArea()

          VStack(spacing: 0) {
            studioTopBar
              .padding(.leading, topBarLeadingPadding)
              .padding(.trailing, 20)
              .padding(.vertical, 14)
              .background(.ultraThinMaterial)
              .overlay(alignment: .bottom) {
                Divider()
                  .overlay(Color.white.opacity(0.08))
              }
              .animation(.spring(response: 0.32, dampingFraction: 0.82), value: effectiveSidebarCollapsed)

            ScrollView {
              VStack(spacing: 24) {
                categoryHeaderView

                switch displayMode {
                case .sideBySide:
                  sideBySideGallery
                case .macOS26:
                  singleVersionGallery(mode: .native, title: "macOS 26+ (Apple Liquid Glass)", badge: "Official API", badgeColor: .blue)
                case .macOS1315:
                  singleVersionGallery(mode: .legacy, title: "macOS 13–15 (Solid Native Fallback)", badge: "Solid Native", badgeColor: .orange)
                }
              }
              .padding(.horizontal, 28)
              .padding(.top, 20)
              .padding(.bottom, 90)
            }
          }

          // Floating Toast Notification
          if let toastMessage {
            HStack(spacing: 8) {
              Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.green)

              Text(toastMessage)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
              Capsule()
                .fill(Color.black.opacity(0.85))
                .overlay(
                  Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
            )
            .padding(.top, 64)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(100)
          }

          // Floating Bottom Dock
          VStack {
            Spacer()
            studioFloatingDock
              .padding(.bottom, 20)
          }
        }
        .frame(minWidth: 580, maxWidth: .infinity)

        // 3. Right Collapsible Inspector
        if isInspectorVisible {
          ResizeDivider(
            width: $inspectorWidth,
            minWidth: 260,
            maxWidth: 360,
            isRight: true
          )
          .ignoresSafeArea(edges: .top)

          studioInspector
            .frame(width: inspectorWidth)
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .ignoresSafeArea(edges: .top)
      .background(SplitViewObserver(isSidebarCollapsed: $isSidebarCollapsed))
    }
    .navigationSplitViewStyle(.prominentDetail)
    .preferredColorScheme(colorSchemeOverride)
    .animation(.easeInOut(duration: 0.22), value: isInspectorVisible)
    .animation(.easeInOut(duration: 0.20), value: displayMode)
    .animation(.easeInOut(duration: 0.18), value: selectedCategory)
    .onAppear {
      LiquidGlassCapabilities.runtimeLegacyOverride = nil
    }
  }

  // MARK: - Sidebar

  private var studioSidebar: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Traffic lights spacing for fullSizeContentView
      Color.clear
        .frame(height: 38)

      // Studio Brand Header
      HStack(spacing: 10) {
        Image(systemName: "drop.halffull")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(Color.accentColor)

        VStack(alignment: .leading, spacing: 1) {
          Text("Snapzy Studio")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(LiquidGlassTokens.inkPrimary)
          Text("Liquid Glass Design System")
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }

        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

      Divider()
        .overlay(Color.white.opacity(0.08))

      // Categories List
      ScrollView {
        VStack(spacing: 4) {
          ForEach(PlaygroundCategory.allCases) { category in
            let isSelected = selectedCategory == category
            let isHovered = hoveredCategory == category

            Button {
              selectedCategory = category
            } label: {
              HStack(spacing: 10) {
                Image(systemName: category.icon)
                  .font(.system(size: 12, weight: .medium))
                  .frame(width: 20)
                  .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                Text(category.title)
                  .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                  .foregroundStyle(isSelected ? .primary : .secondary)
                  .lineLimit(1)
                  .fixedSize(horizontal: true, vertical: false)

                Spacer()
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                  .fill(isSelected ? Color.accentColor.opacity(0.16) : (isHovered ? Color.white.opacity(0.06) : Color.clear))
              )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
              if hovering { hoveredCategory = category }
              else if hoveredCategory == category { hoveredCategory = nil }
            }
          }
        }
        .padding(.horizontal, 10)
        .padding(.top, 12)
      }

      Spacer()

      Divider()
        .overlay(Color.white.opacity(0.08))

      // Host OS Status Pill
      HStack(spacing: 8) {
        Circle()
          .fill(LiquidGlassCapabilities.isSystemSupported ? Color.green : Color.orange)
          .frame(width: 7, height: 7)

        VStack(alignment: .leading, spacing: 2) {
          Text(LiquidGlassCapabilities.isSystemSupported ? "macOS 26+ Native Ready" : "macOS 13–15 Compatible")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(LiquidGlassTokens.inkPrimary)
          Text(LiquidGlassCapabilities.forcesLegacyGlass ? "Forced Solid Fallback" : "Auto Adaptive Mode")
            .font(.system(size: 9.5))
            .foregroundStyle(.secondary)
        }

        Spacer()
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(Color.black.opacity(0.18))
    }
    .frame(minWidth: 210, maxWidth: .infinity, maxHeight: .infinity)
    .background(
      LiquidGlassVibrancyBackdrop(material: .sidebar, blending: .behindWindow)
        .overlay(Color.black.opacity(0.24))
    )
  }

  // MARK: - Top Toolbar

  private var studioTopBar: some View {
    HStack(spacing: 12) {
      // Display Mode Picker
      Picker("", selection: $displayMode) {
        ForEach(PlaygroundDisplayMode.allCases) { mode in
          Text(mode.title).tag(mode)
        }
      }
      .labelsHidden()
      .pickerStyle(.segmented)
      .frame(maxWidth: 460)

      Spacer()

      // Wallpaper Selector
      Picker("Background", selection: $selectedWallpaper) {
        ForEach(PlaygroundWallpaper.allCases) { wp in
          Text(wp.title).tag(wp)
        }
      }
      .pickerStyle(.menu)
      .frame(width: 140)

      // Light/Dark Theme Switcher
      Button {
        if colorSchemeOverride == .dark {
          colorSchemeOverride = .light
        } else if colorSchemeOverride == .light {
          colorSchemeOverride = nil
        } else {
          colorSchemeOverride = .dark
        }
      } label: {
        Image(systemName: colorSchemeOverride == .dark ? "moon.fill" : (colorSchemeOverride == .light ? "sun.max.fill" : "circle.lefthalf.filled"))
          .font(.system(size: 12))
          .frame(width: 28, height: 24)
      }
      .buttonStyle(.bordered)
      .help("Toggle Dark / Light / System Appearance")

      // Inspector Toggle Button
      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
          isInspectorVisible.toggle()
        }
      } label: {
        Image(systemName: "sidebar.trailing")
          .font(.system(size: 12, weight: isInspectorVisible ? .bold : .regular))
          .foregroundStyle(isInspectorVisible ? Color.accentColor : .primary)
          .frame(width: 28, height: 24)
      }
      .buttonStyle(.bordered)
      .keyboardShortcut("i", modifiers: [.command, .option])
      .help("Toggle Inspector Panel (⌥⌘I)")

      // Native Sidebar Toggle Shortcut (⌘⌥S)
      Button {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
          if columnVisibility == .detailOnly || isSidebarCollapsed {
            columnVisibility = .all
            isSidebarCollapsed = false
          } else {
            columnVisibility = .detailOnly
            isSidebarCollapsed = true
          }
        }
        NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
      } label: {
        EmptyView()
      }
      .keyboardShortcut("s", modifiers: [.command, .option])
      .frame(width: 0, height: 0)
      .opacity(0)
    }
  }

  // MARK: - Floating Bottom Dock

  private var studioFloatingDock: some View {
    HStack(spacing: 12) {
      // Action 1: Copy Active Category Swift Code
      Button {
        let snippet = snippetForCategory(selectedCategory)
        copyCode(snippet, title: selectedCategory.title)
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "doc.on.doc")
            .font(.system(size: 11, weight: .semibold))
          Text("Copy \(selectedCategory.title)")
            .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
          Capsule()
            .fill(Color.white.opacity(0.1))
        )
      }
      .buttonStyle(.plain)

      Divider()
        .frame(height: 14)
        .overlay(Color.white.opacity(0.2))

      // Action 2: Reset All Optical Tuning
      Button {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
          tuning = LiquidGlassTuning.default
        }
        copyCode("// Restored default Liquid Glass parameters", title: "Reset Parameters")
      } label: {
        HStack(spacing: 5) {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 10, weight: .bold))
          Text("Reset Tuning")
            .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(.secondary)
      }
      .buttonStyle(.plain)

      Divider()
        .frame(height: 14)
        .overlay(Color.white.opacity(0.2))

      // Action 3: Simulator State Quick Toggle
      Button {
        if !simulateDisabled && !simulateBusy {
          simulateDisabled = true
        } else if simulateDisabled {
          simulateDisabled = false
          simulateBusy = true
        } else {
          simulateBusy = false
        }
      } label: {
        HStack(spacing: 5) {
          Circle()
            .fill(simulateDisabled ? Color.orange : (simulateBusy ? Color.blue : Color.green))
            .frame(width: 7, height: 7)
          Text(simulateDisabled ? "State: Disabled" : (simulateBusy ? "State: Busy" : "State: Normal"))
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 7)
    .background(
      Capsule()
        .fill(Color.black.opacity(0.75))
        .overlay(
          Capsule()
            .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.35), radius: 12, y: 5)
    )
  }

  // MARK: - Code Snippet Generator & Clipboard Helpers

  private func copyCode(_ snippet: String, title: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(snippet, forType: .string)

    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
      toastMessage = "Copied: \(title)"
      hasCopiedCode = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
      withAnimation(.easeInOut(duration: 0.25)) {
        if toastMessage?.contains(title) == true {
          toastMessage = nil
        }
        hasCopiedCode = false
      }
    }
  }

  private func snippetForCategory(_ category: PlaygroundCategory) -> String {
    switch category {
    case .overview:
      return """
      // Liquid Glass Tokens
      let inkPrimary = LiquidGlassTokens.inkPrimary
      let inkBody = LiquidGlassTokens.inkBody
      let substrateResting = LiquidGlassTokens.controlSubstrateResting
      """
    case .buttons:
      return """
      LiquidGlassActionButton(
        title: "Save",
        icon: "square.and.arrow.down",
        trailingKey: "⌘S",
        emphasis: .primary,
        capsule: true
      ) {
        // Handle action
      }
      """
    case .segmented:
      return """
      LiquidGlassSegmentedControl(items: ["Capture", "Record", "OCR"], selection: $selectedTab) { item in
        Text(item)
      }
      """
    case .toolbars:
      return """
      HStack(spacing: 8) {
        Button(...) { ... }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .liquidGlassSurface(shape: Capsule(), layer: .control)
      """
    case .cards:
      return """
      VStack(alignment: .leading, spacing: 10) {
        Text("Card Content")
      }
      .padding(14)
      .liquidGlass(
        shape: RoundedRectangle(cornerRadius: LiquidGlassTokens.cardRadius, style: .continuous),
        substrate: LiquidGlassTokens.baseDarkness
      )
      """
    case .forms:
      return """
      HStack {
        Image(systemName: "magnifyingglass")
        TextField("Search...", text: $query)
      }
      .padding(8)
      .liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 8), layer: .control)
      """
    case .mockups:
      return """
      // Full Quick Access Floating Card Mockup
      QuickAccessFloatingCard(image: capturedImage)
        .liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 12), layer: .overlay)
      """
    }
  }

  // MARK: - Category Header

  private var categoryHeaderView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 3) {
        HStack(spacing: 8) {
          Image(systemName: selectedCategory.icon)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Color.accentColor)

          Text(selectedCategory.title)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.primary)
        }

        Text(selectedCategory.subtitle)
          .font(.system(size: 11.5))
          .foregroundStyle(Color.secondary)
      }

      Spacer()

      Button {
        let snippet = snippetForCategory(selectedCategory)
        copyCode(snippet, title: selectedCategory.title)
      } label: {
        HStack(spacing: 5) {
          Image(systemName: "doc.on.doc")
            .font(.system(size: 10.5))
          Text("Copy Swift Code")
            .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
          Capsule()
            .fill(Color.white.opacity(0.08))
            .overlay(
              Capsule()
                .stroke(Color.white.opacity(0.14), lineWidth: 0.5)
            )
        )
      }
      .buttonStyle(.plain)
      .help("Copy sample code for this component group")
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 14)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
    )
  }

  // MARK: - Galleries

  private var sideBySideGallery: some View {
    HStack(alignment: .top, spacing: 20) {
      // Left Column: Native Liquid Glass (macOS 26+)
      VStack(spacing: 16) {
        columnHeader(title: "macOS 26+ (Apple Liquid Glass)", badge: "Official API", badgeColor: .blue)

        categoryContent(for: selectedCategory, mode: .native)
      }
      .environment(\.liquidGlassRenderMode, .native)
      .frame(maxWidth: .infinity)

      // Right Column: Solid Native Fallback (macOS 13–15)
      VStack(spacing: 16) {
        columnHeader(title: "macOS 13–15 (Solid Native Fallback)", badge: "Solid Native", badgeColor: .orange)

        categoryContent(for: selectedCategory, mode: .legacy)
      }
      .environment(\.liquidGlassRenderMode, .legacy)
      .environment(\.liquidGlassTuning, tuning)
      .frame(maxWidth: .infinity)
    }
  }

  private func singleVersionGallery(mode: LiquidGlassRenderMode, title: String, badge: String, badgeColor: Color) -> some View {
    VStack(spacing: 18) {
      columnHeader(title: title, badge: badge, badgeColor: badgeColor)

      categoryContent(for: selectedCategory, mode: mode)
        .frame(maxWidth: 680)
    }
    .environment(\.liquidGlassRenderMode, mode)
    .environment(\.liquidGlassTuning, mode == .legacy ? tuning : nil)
  }

  private func columnHeader(title: String, badge: String, badgeColor: Color) -> some View {
    HStack(spacing: 8) {
      Text(title)
        .font(.system(size: 12.5, weight: .bold))
        .foregroundStyle(LiquidGlassTokens.inkPrimary)

      Text(badge)
        .font(.system(size: 9.5, weight: .semibold))
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(badgeColor.opacity(0.18))
        .foregroundStyle(badgeColor)
        .clipShape(Capsule())
    }
    .padding(.vertical, 3)
  }

  // MARK: - Category Content Switcher

  @ViewBuilder
  private func categoryContent(for category: PlaygroundCategory, mode: LiquidGlassRenderMode) -> some View {
    switch category {
    case .overview:
      overviewSection(mode: mode)
    case .buttons:
      buttonsSection(mode: mode)
    case .segmented:
      segmentedSection(mode: mode)
    case .toolbars:
      toolbarsSection(mode: mode)
    case .cards:
      cardsSection(mode: mode)
    case .forms:
      formsSection(mode: mode)
    case .mockups:
      mockupsSection(mode: mode)
    }
  }

  // MARK: - 1. Overview & Tokens

  private func overviewSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 16) {
      studioCard(
        "Color & Ink Tokens",
        subtitle: "Dynamic text and icon colors adaptable to light/dark backgrounds",
        codeSnippet: "// Ink Tokens\nlet primary = LiquidGlassTokens.inkPrimary\nlet body = LiquidGlassTokens.inkBody\nlet muted = LiquidGlassTokens.inkMuted"
      ) {
        VStack(spacing: 10) {
          HStack(spacing: 12) {
            tokenSwatch(name: "inkPrimary", color: LiquidGlassTokens.inkPrimary, subtitle: "Primary Text")
            tokenSwatch(name: "inkBody", color: LiquidGlassTokens.inkBody, subtitle: "Body Content")
            tokenSwatch(name: "inkMuted", color: LiquidGlassTokens.inkMuted, subtitle: "Hint / Disabled")
          }

          HStack(spacing: 12) {
            tokenSwatch(name: "Accent Blue", color: .accentColor, subtitle: "Primary Action")
            tokenSwatch(name: "Destructive", color: .red, subtitle: "Delete / Warning")
            tokenSwatch(name: "Glass Tint", color: .white.opacity(0.18), subtitle: "Neutral Layer")
          }
        }
      }

      studioCard(
        "Substrate Levels",
        subtitle: "Substrate background opacity for secondary button states",
        codeSnippet: "// Substrate Opacity Values\nlet resting = LiquidGlassTokens.controlSubstrateResting // 0.45\nlet hover = LiquidGlassTokens.controlSubstrateHover // 0.60\nlet pressed = LiquidGlassTokens.controlSubstratePressed // 0.72"
      ) {
        HStack(spacing: 12) {
          VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.black.opacity(LiquidGlassTokens.controlSubstrateResting))
              .frame(height: 38)
              .overlay(Text("0.45").font(.caption.monospacedDigit()).foregroundStyle(.white))
            Text("Resting").font(.system(size: 10.5)).foregroundStyle(.secondary)
          }

          VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.black.opacity(LiquidGlassTokens.controlSubstrateHover))
              .frame(height: 38)
              .overlay(Text("0.60").font(.caption.monospacedDigit()).foregroundStyle(.white))
            Text("Hover").font(.system(size: 10.5)).foregroundStyle(.secondary)
          }

          VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.black.opacity(LiquidGlassTokens.controlSubstratePressed))
              .frame(height: 38)
              .overlay(Text("0.72").font(.caption.monospacedDigit()).foregroundStyle(.white))
            Text("Pressed").font(.system(size: 10.5)).foregroundStyle(.secondary)
          }
        }
      }

      studioCard(
        "Geometry & Hairline Physics",
        subtitle: "Corner radii derived from control height and 0.5pt hairline border",
        codeSnippet: Self.radiusSnippet
      ) {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Text("Specular Hairline 0.5pt:")
              .font(.system(size: 11, weight: .medium))
            Spacer()
            Text("Top: 0.22 • Bottom: 0.06")
              .font(.system(size: 11))
              .foregroundStyle(.secondary)
          }

          // Rendered from `Radius` rather than described in prose, so the strip cannot go stale
          // the way the old hardcoded "controlRadius: 8" caption did.
          HStack(alignment: .bottom, spacing: 10) {
            ForEach(Self.radiusRamp, id: \.height) { step in
              radiusSample(height: step.height, label: step.label)
            }
          }

          HStack(spacing: 8) {
            radiusChip("card", Radius.card)
            radiusChip("panel", Radius.panel)
            radiusChip("window", Radius.window)
            Text("Capsule — action buttons & segmented pickers only")
              .font(.system(size: 10))
              .foregroundStyle(.secondary)
          }
        }
      }
    }
  }

  private struct RadiusStep {
    let height: CGFloat
    let label: String
  }

  /// The control heights the app actually ships, so the strip doubles as an audit.
  private static let radiusRamp: [RadiusStep] = [
    RadiusStep(height: 18, label: "keycap"),
    RadiusStep(height: 24, label: "chip"),
    RadiusStep(height: 28, label: "toolbar"),
    RadiusStep(height: 32, label: "recording"),
    RadiusStep(height: 38, label: "stacked"),
  ]

  private static var radiusSnippet: String {
    let rows = radiusRamp
      .map { "// \($0.label) \(Int($0.height))pt → \(Int(Radius.control(forHeight: $0.height)))pt" }
      .joined(separator: "\n")
    return """
    // Radius is derived from control height (~\(Radius.controlRoundness) × h)
    \(rows)
    let shape = Radius.controlRect(forHeight: 28)
    """
  }

  private func radiusSample(height: CGFloat, label: String) -> some View {
    let radius = Radius.control(forHeight: height)
    return VStack(spacing: 4) {
      Radius.rect(radius)
        .fill(Color.secondary.opacity(0.22))
        .overlay(Radius.rect(radius).strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5))
        .frame(width: max(height, 44), height: height)
      Text("\(Int(height))→\(Int(radius))")
        .font(.system(size: 9, weight: .semibold).monospacedDigit())
      Text(label)
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
    }
  }

  private func radiusChip(_ name: String, _ radius: CGFloat) -> some View {
    Text("\(name) \(Int(radius))pt")
      .font(.system(size: 10.5))
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(Radius.rect(Radius.controlXS).fill(.secondary.opacity(0.15)))
  }

  private func tokenSwatch(name: String, color: Color, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      RoundedRectangle(cornerRadius: 6)
        .fill(color)
        .frame(height: 28)
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
      Text(name)
        .font(.system(size: 10, weight: .bold))
      Text(subtitle)
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: - 2. Buttons & Actions

  private func buttonsSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 16) {
      studioCard(
        "Emphasis Levels",
        subtitle: "Primary, Secondary, Destructive, and Ghost",
        codeSnippet: "LiquidGlassActionButton(\n  title: \"Save\",\n  icon: \"square.and.arrow.down\",\n  trailingKey: \"⌘S\",\n  emphasis: .primary,\n  capsule: true\n) {\n  // Action\n}"
      ) {
        VStack(spacing: 8) {
          HStack(spacing: 8) {
            LiquidGlassActionButton(
              title: "Save",
              icon: "square.and.arrow.down",
              trailingKey: "⌘S",
              emphasis: .primary,
              capsule: true
            ) {}
            .disabled(simulateDisabled)

            LiquidGlassActionButton(
              title: "Copy",
              trailingKey: "⌘C",
              emphasis: .secondary,
              capsule: true
            ) {}
            .disabled(simulateDisabled)
          }

          HStack(spacing: 8) {
            LiquidGlassActionButton(
              title: "Delete",
              icon: "trash",
              emphasis: .destructive,
              capsule: true
            ) {}
            .disabled(simulateDisabled)

            Button("Ghost / Subtle") {}
              .buttonStyle(LiquidGlassButtonStyle(emphasis: .contextPill, capsule: false))
              .disabled(simulateDisabled)
          }

          HStack(spacing: 8) {
            Button("Active Filter") {
              isActionActive.toggle()
            }
            .buttonStyle(LiquidGlassButtonStyle(emphasis: .secondary, capsule: false, isActive: isActionActive))
            .disabled(simulateDisabled)

            if simulateBusy {
              HStack(spacing: 6) {
                ProgressView()
                  .controlSize(.small)
                Text("Processing...")
                  .font(.system(size: 11, weight: .medium))
              }
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(Capsule().fill(.black.opacity(0.5)))
              .foregroundStyle(.white)
            }
          }
        }
      }

      studioCard(
        "Shape & Size Variants",
        subtitle: "Capsule vs Rounded Rectangle variants",
        codeSnippet: "LiquidGlassActionButton(\n  title: \"Capsule Regular\",\n  icon: \"star.fill\",\n  emphasis: .secondary,\n  capsule: true\n) {}"
      ) {
        VStack(spacing: 10) {
          HStack(spacing: 8) {
            LiquidGlassActionButton(
              title: "Capsule Regular",
              icon: "star.fill",
              emphasis: .secondary,
              capsule: true
            ) {}
            .disabled(simulateDisabled)

            LiquidGlassActionButton(
              title: "Rounded Rect",
              icon: "slider.horizontal.3",
              emphasis: .secondary,
              capsule: false
            ) {}
            .disabled(simulateDisabled)
          }
        }
      }

      studioCard(
        "Icon Action Grid",
        subtitle: "Icon action buttons used in toolbars and previews",
        codeSnippet: "Button {\n  // Action\n} label: {\n  Image(systemName: \"crop\")\n    .frame(width: 28, height: 28)\n}\n.buttonStyle(LiquidGlassButtonStyle(emphasis: .secondary, capsule: false))"
      ) {
        HStack(spacing: 10) {
          ForEach(["crop", "pencil.tip", "character", "arrow.up.right", "hand.draw", "trash"], id: \.self) { iconName in
            let isActive = iconName == "pencil.tip" && isToolbarToggleActive

            Button {
              if iconName == "pencil.tip" {
                isToolbarToggleActive.toggle()
              }
            } label: {
              Image(systemName: iconName)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 28, height: 28)
                .foregroundStyle(isActive ? LiquidGlassTokens.ink(onTint: .accentColor, renderMode: mode) : LiquidGlassTokens.inkPrimary)
            }
            .buttonStyle(LiquidGlassButtonStyle(emphasis: isActive ? .primary : .secondary, capsule: false))
            .disabled(simulateDisabled)
          }
        }
      }
    }
  }

  // MARK: - 3. Segmented Controls

  private func segmentedSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 16) {
      studioCard(
        "Sliding Pill Tabs",
        subtitle: "Standard segmented control with fluid spring motion",
        codeSnippet: "LiquidGlassSegmentedControl(items: [\"Capture\", \"Record\", \"OCR\"], selection: $selectedTab) {\n  Text($0)\n}"
      ) {
        VStack(spacing: 12) {
          LiquidGlassSegmentedControl(items: tabs, selection: $selectedTab) { tab in
            Text(tab)
          }

          HStack {
            Text("Selected:")
              .font(.system(size: 11))
              .foregroundStyle(.secondary)
            Text(selectedTab)
              .font(.system(size: 11, weight: .bold))
              .foregroundStyle(Color.accentColor)
          }
        }
      }

      studioCard(
        "Capture Mode Selector",
        subtitle: "Capture mode selector with symbols",
        codeSnippet: "LiquidGlassActionButton(\n  title: \"Fullscreen\",\n  icon: \"display\",\n  emphasis: .primary,\n  capsule: true\n) {}"
      ) {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
          ForEach([("Fullscreen", "display"), ("Area", "crop"), ("Window", "macwindow"), ("Scrolling", "arrow.down.doc")], id: \.0) { item in
            let isSelected = selectedTab == item.0

            Button {
              selectedTab = item.0
            } label: {
              HStack(spacing: 6) {
                Image(systemName: item.1)
                  .font(.system(size: 11))
                Text(item.0)
                  .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
              }
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .foregroundStyle(isSelected ? LiquidGlassTokens.ink(onTint: .accentColor, renderMode: mode) : LiquidGlassTokens.inkPrimary)
            }
            .buttonStyle(LiquidGlassButtonStyle(emphasis: isSelected ? .primary : .secondary, capsule: true))
          }
        }
      }
    }
  }

  // MARK: - 4. Toolbars & Docks

  private func toolbarsSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 16) {
      studioCard(
        "Annotate Floating Dock",
        subtitle: "Floating toolbar with drawing tools, palette, and actions",
        codeSnippet: "HStack(spacing: 6) {\n  // Tools...\n}\n.padding(.horizontal, 10)\n.padding(.vertical, 6)\n.liquidGlassSurface(shape: Capsule(), layer: .control)"
      ) {
        VStack(spacing: 12) {
          HStack(spacing: 6) {
            Group {
              Button {} label: { Image(systemName: "cursorarrow").frame(width: 22, height: 22) }
              Button {} label: { Image(systemName: "rectangle").frame(width: 22, height: 22) }
              Button {} label: { Image(systemName: "arrow.up.right").frame(width: 22, height: 22) }
              Button {} label: { Image(systemName: "pencil").frame(width: 22, height: 22) }
              Button {} label: { Image(systemName: "textformat").frame(width: 22, height: 22) }
            }
            .buttonStyle(LiquidGlassButtonStyle(emphasis: .secondary, capsule: false))

            Divider().frame(height: 18).padding(.horizontal, 2)

            // Color Palette
            HStack(spacing: 4) {
              ForEach(0..<colors.count, id: \.self) { idx in
                Circle()
                  .fill(colors[idx])
                  .frame(width: 14, height: 14)
                  .overlay(
                    Circle()
                      .stroke(Color.white, lineWidth: selectedColorIndex == idx ? 2 : 0)
                  )
                  .onTapGesture {
                    selectedColorIndex = idx
                  }
              }
            }

            Divider().frame(height: 18).padding(.horizontal, 2)

            Button {} label: { Image(systemName: "arrow.uturn.backward").frame(width: 22, height: 22) }
              .buttonStyle(LiquidGlassButtonStyle(emphasis: .secondary, capsule: false))
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .liquidGlassSurface(shape: Capsule(), layer: .control)
        }
      }

      studioCard(
        "Recording Control Dock",
        subtitle: "Screen recording control dock with real-time timer",
        codeSnippet: "HStack(spacing: 12) {\n  Text(\"01:42\")\n  LiquidGlassActionButton(title: \"Pause\", icon: \"pause.fill\", emphasis: .secondary, capsule: true) {}\n  LiquidGlassActionButton(title: \"Stop\", icon: \"stop.fill\", emphasis: .destructive, capsule: true) {}\n}\n.padding(.horizontal, 14)\n.padding(.vertical, 7)\n.liquidGlassSurface(shape: Capsule(), layer: .control)"
      ) {
        HStack(spacing: 12) {
          HStack(spacing: 6) {
            Circle()
              .fill(.red)
              .frame(width: 8, height: 8)

            Text("01:42")
              .font(.system(size: 12, weight: .bold).monospacedDigit())
              .foregroundStyle(.primary)
          }

          Divider().frame(height: 16)

          HStack(spacing: 8) {
            LiquidGlassActionButton(title: "Pause", icon: "pause.fill", emphasis: .secondary, capsule: true) {}
            LiquidGlassActionButton(title: "Stop", icon: "stop.fill", emphasis: .destructive, capsule: true) {}
          }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .liquidGlassSurface(shape: Capsule(), layer: .control)
      }
    }
  }

  // MARK: - 5. Cards & Overlays

  private func cardsSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 16) {
      studioCard(
        "Quick Access Floating Card",
        subtitle: "Floating capture result card in the bottom-right corner",
        codeSnippet: "VStack(alignment: .leading, spacing: 10) {\n  Text(\"Screenshot.png\")\n  // Preview...\n  HStack { ... }\n}\n.padding(14)\n.liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 12), layer: .control)"
      ) {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Image(systemName: "camera.fill")
              .font(.system(size: 11))
              .foregroundStyle(Color.accentColor)
            Text("Snapzy_2026-09-12_13-40.png")
              .font(.system(size: 11, weight: .bold))
              .lineLimit(1)
            Spacer()
            Text("PNG • 2.1 MB")
              .font(.system(size: 9.5))
              .foregroundStyle(.secondary)
          }

          // Fake Thumbnail
          RoundedRectangle(cornerRadius: 8)
            .fill(
              LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(height: 90)
            .overlay(
              Image(systemName: "photo")
                .font(.system(size: 24))
                .foregroundStyle(.white.opacity(0.7))
            )

          // Card Action Buttons
          HStack(spacing: 8) {
            LiquidGlassActionButton(title: "Copy", icon: "doc.on.doc", trailingKey: "⌘C", emphasis: .secondary, capsule: true) {}
            LiquidGlassActionButton(title: "Annotate", icon: "pencil", emphasis: .secondary, capsule: true) {}
            Spacer()
            LiquidGlassActionButton(title: "Save", icon: "arrow.down", emphasis: .primary, capsule: true) {}
          }
        }
        .padding(14)
        .liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 12), layer: .control)
        .shadow(color: .black.opacity(0.14), radius: 10, y: 5)
      }

      studioCard(
        "Notification Toast HUD",
        subtitle: "Floating status HUD (OCR, clipboard)",
        codeSnippet: "HStack(spacing: 8) {\n  Image(systemName: \"checkmark.circle.fill\").foregroundStyle(.green)\n  Text(\"Copied\")\n}\n.padding(.horizontal, 14)\n.padding(.vertical, 9)\n.liquidGlassSurface(shape: Capsule(), layer: .control)"
      ) {
        HStack(spacing: 8) {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 14))
            .foregroundStyle(.green)

          Text("Screenshot copied to clipboard")
            .font(.system(size: 11.5, weight: .medium))

          Spacer()

          Text("⌘V")
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Capsule().fill(.secondary.opacity(0.2)))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .liquidGlassSurface(shape: Capsule(), layer: .control)
      }
    }
  }

  // MARK: - 6. Form Controls

  private func formsSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 16) {
      studioCard(
        "Glass Search Field",
        subtitle: "Real-time glass-morphic search input",
        codeSnippet: "HStack(spacing: 8) {\n  Image(systemName: \"magnifyingglass\")\n  TextField(\"Search...\", text: $query)\n}\n.padding(.horizontal, 10)\n.padding(.vertical, 7)\n.liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 8), layer: .control)"
      ) {
        HStack(spacing: 8) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)

          TextField("Search capture history, notes...", text: $searchQuery)
            .textFieldStyle(.plain)
            .font(.system(size: 12))

          if !searchQuery.isEmpty {
            Button {
              searchQuery = ""
            } label: {
              Image(systemName: "xmark.circle.fill")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 8), layer: .control)
      }

      studioCard(
        "Glass Sliders & Toggles",
        subtitle: "Tuning sliders and toggle switches",
        codeSnippet: "Slider(value: $sliderValue, in: 0...1)\nToggle(\"Auto-open Annotate\", isOn: $toggleValue)\n  .toggleStyle(.switch)"
      ) {
        VStack(spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            HStack {
              Text("Opacity:")
                .font(.system(size: 11, weight: .medium))
              Spacer()
              Text("\(Int(sliderValue * 100))%")
                .font(.system(size: 11).monospacedDigit())
                .foregroundStyle(.secondary)
            }
            Slider(value: $sliderValue, in: 0...1)
          }

          Divider()

          Toggle("Auto-open Annotate after capture", isOn: $toggleValue)
            .font(.system(size: 11.5))
            .toggleStyle(.switch)
        }
      }
    }
  }

  // MARK: - 7. Feature Mockups

  private func mockupsSection(mode: LiquidGlassRenderMode) -> some View {
    VStack(spacing: 18) {
      studioCard(
        "Full Workspace Preview",
        subtitle: "Integrated simulation of Quick Access card and tool dock",
        codeSnippet: "// Workspace Preview with Floating Quick Access & Dock\nQuickAccessFloatingCard()\n  .liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 12), layer: .control)"
      ) {
        ZStack {
          // Inner Wallpaper Canvas
          RoundedRectangle(cornerRadius: 12)
            .fill(
              LinearGradient(
                colors: [Color(red: 0.15, green: 0.20, blue: 0.32), Color(red: 0.08, green: 0.10, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(height: 240)
            .overlay(alignment: .top) {
              // Floating Toolbar in Mockup
              HStack(spacing: 8) {
                Image(systemName: "camera.viewfinder")
                  .font(.system(size: 11, weight: .bold))
                  .foregroundStyle(Color.accentColor)

                Text("Area Capture")
                  .font(.system(size: 11, weight: .semibold))
                  .foregroundStyle(.white)

                Text("1920 × 1080")
                  .font(.system(size: 10).monospacedDigit())
                  .foregroundStyle(.white.opacity(0.6))
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .liquidGlassSurface(shape: Capsule(), layer: .control)
              .padding(.top, 14)
            }
            .overlay(alignment: .bottomTrailing) {
              // Mini Quick Access Card
              HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                  .fill(Color.blue.opacity(0.4))
                  .frame(width: 44, height: 32)
                  .overlay(Image(systemName: "photo").font(.system(size: 12)).foregroundStyle(.white))

                VStack(alignment: .leading, spacing: 1) {
                  Text("Quick Capture")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundStyle(.white)
                  Text("Press ⌘C to copy")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.7))
                }

                LiquidGlassActionButton(title: "Copy", trailingKey: "⌘C", emphasis: .primary, capsule: true) {}
              }
              .padding(8)
              .liquidGlassSurface(shape: RoundedRectangle(cornerRadius: 10), layer: .control)
              .shadow(radius: 6)
              .padding(14)
            }
        }
      }
    }
  }

  // MARK: - Reusable Studio Card

  private func studioCard<Content: View>(
    _ title: String,
    subtitle: String? = nil,
    codeSnippet: String? = nil,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.system(size: 12.5, weight: .bold))
            .foregroundStyle(LiquidGlassTokens.inkPrimary)

          if let subtitle {
            Text(subtitle)
              .font(.system(size: 10))
              .foregroundStyle(LiquidGlassTokens.inkMuted)
          }
        }

        Spacer()

        if let snippet = codeSnippet {
          Button {
            copyCode(snippet, title: title)
          } label: {
            HStack(spacing: 4) {
              Image(systemName: "doc.on.doc")
                .font(.system(size: 9.5))
              Text("Copy Code")
                .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3.5)
            .background(
              RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.06))
            )
          }
          .buttonStyle(.plain)
          .help("Copy Swift code for this component")
        }
      }

      content()
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(NSColor.controlBackgroundColor).opacity(0.45))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    )
  }

  // MARK: - Studio Inspector

  private var studioInspector: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Inspector Header with traffic light clearance
      HStack {
        Image(systemName: "slider.horizontal.below.square.and.square.filled")
          .font(.system(size: 12))
          .foregroundStyle(Color.accentColor)

        Text("Inspector & Tuning")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(LiquidGlassTokens.inkPrimary)

        Spacer()

        Button {
          withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            tuning = LiquidGlassTuning.default
          }
          copyCode("// Restored default parameters", title: "Reset Parameters")
        } label: {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        .help("Reset all parameters to default")

        Button {
          withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            isInspectorVisible = false
          }
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.secondary)
            .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        .help("Close Inspector")
      }
      .padding(.horizontal, 16)
      .padding(.top, 38)
      .padding(.bottom, 12)

      Divider()
        .overlay(Color.white.opacity(0.08))

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          // Accordion 1: Global Settings
          AccordionSection(title: "Global Application", isExpanded: $expandGlobalSection) {
            inspectorGlobalSection
          }

          // Accordion 2: Interactive Simulator
          AccordionSection(title: "Interactive Simulator", isExpanded: $expandSimulatorSection) {
            inspectorSimulatorSection
          }

          // Accordion 3: Optical Tuning Sliders
          AccordionSection(
            title: "macOS 13–15 Parameters",
            isExpanded: $expandTuningSection,
            onReset: {
              withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                tuning = LiquidGlassTuning.default
              }
            }
          ) {
            inspectorSlidersSection
          }

          // Accordion 4: Composite Layers
          AccordionSection(title: "Glass Layers Breakdown", isExpanded: $expandLayersSection) {
            inspectorLayersSection
          }

          // Accordion 5: Code Exporter
          AccordionSection(title: "Export Swift Code", isExpanded: $expandExportSection) {
            inspectorExportSection
          }
        }
      }
    }
    .background(
      LiquidGlassVibrancyBackdrop(material: .hudWindow, blending: .withinWindow)
        .overlay(Color.black.opacity(0.18))
    )
  }

  private var inspectorGlobalSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Toggle("Liquid Glass Effect", isOn: $useLiquidGlass)
        .toggleStyle(.switch)
        .controlSize(.small)
        .onChange(of: useLiquidGlass) { _ in
          LiquidGlassCapabilities.runtimeLegacyOverride = nil
          SnapzyConfigurationSyncCoordinator.shared.scheduleSync(reason: .explicitChange)
        }

      HStack(spacing: 4) {
        Image(systemName: "arrow.triangle.2.circlepath")
          .font(.system(size: 9))
        Text("Synced directly from General Settings")
          .font(.system(size: 9.5))
      }
      .foregroundStyle(.secondary)

      Text(useLiquidGlass
           ? "App uses macOS 26+ Apple Glass (or Solid Fallback on older macOS)."
           : "All windows currently using Solid Native Fallback.")
        .font(.system(size: 10))
        .foregroundStyle(useLiquidGlass ? Color.secondary : Color.orange)
        .lineSpacing(1.5)
    }
  }

  private var inspectorSimulatorSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Toggle("Simulate Disabled State", isOn: $simulateDisabled)
        .toggleStyle(.switch)
        .controlSize(.small)
        .font(.system(size: 11))

      Toggle("Simulate Busy / Loading", isOn: $simulateBusy)
        .toggleStyle(.switch)
        .controlSize(.small)
        .font(.system(size: 11))
    }
  }

  private var inspectorSlidersSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Drag sliders or double-click numeric values to reset:")
        .font(.system(size: 10))
        .foregroundStyle(.secondary)
        .padding(.bottom, 2)

      StudioSliderRow(
        title: "1. Substrate",
        cgFloatValue: $tuning.substrateOpacity,
        range: 0.0...0.80,
        step: 0.02,
        defaultValue: Double(LiquidGlassTokens.baseDarkness)
      )

      StudioSliderRow(
        title: "2. Sheen Top",
        value: $tuning.sheenTopOpacity,
        range: 0.0...0.40,
        step: 0.01,
        defaultValue: LiquidGlassTokens.fallbackControlSheenTop
      )

      StudioSliderRow(
        title: "3. Sheen Btm",
        value: $tuning.sheenBottomOpacity,
        range: 0.0...0.30,
        step: 0.01,
        defaultValue: LiquidGlassTokens.fallbackControlSheenBottom
      )

      StudioSliderRow(
        title: "4. Specular Top",
        value: $tuning.specularTopOpacity,
        range: 0.0...0.50,
        step: 0.02,
        defaultValue: 0.22
      )

      StudioSliderRow(
        title: "5. Specular Btm",
        value: $tuning.specularBottomOpacity,
        range: 0.0...0.30,
        step: 0.01,
        defaultValue: 0.06
      )
    }
  }

  private var inspectorLayersSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Toggle("Layer 1: Base Substrate", isOn: $tuning.isSubstrateEnabled)
      Toggle("Layer 2: Refraction Sheen", isOn: $tuning.isRefractionEnabled)
      Toggle("Layer 3: Body Veil / Wash", isOn: $tuning.isVeilEnabled)
      Toggle("Layer 4: Specular Border 0.5pt", isOn: $tuning.isSpecularEnabled)
      Toggle("Rim Lighting (Curved Border)", isOn: $tuning.isRimLightingEnabled)
    }
    .toggleStyle(.switch)
    .controlSize(.small)
    .font(.system(size: 11))
  }

  private var inspectorExportSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Current Configuration:")
        .font(.system(size: 10))
        .foregroundStyle(.secondary)

      Text(generatedTuningCode)
        .font(.system(size: 9.5, design: .monospaced))
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.08), lineWidth: 0.5))

      Button {
        copyCode(generatedTuningCode, title: "Tuning Configuration")
      } label: {
        HStack {
          Image(systemName: hasCopiedCode ? "checkmark" : "doc.on.doc")
          Text(hasCopiedCode ? "Copied Swift Code!" : "Copy Swift Tokens")
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .tint(hasCopiedCode ? .green : .accentColor)
      .controlSize(.regular)
    }
  }

  private var generatedTuningCode: String {
    """
    let tuning = LiquidGlassTuning(
      substrateOpacity: \(String(format: "%.2f", tuning.substrateOpacity)),
      sheenTopOpacity: \(String(format: "%.2f", tuning.sheenTopOpacity)),
      sheenBottomOpacity: \(String(format: "%.2f", tuning.sheenBottomOpacity)),
      specularTopOpacity: \(String(format: "%.2f", tuning.specularTopOpacity)),
      specularBottomOpacity: \(String(format: "%.2f", tuning.specularBottomOpacity)),
      isSubstrateEnabled: \(tuning.isSubstrateEnabled),
      isRefractionEnabled: \(tuning.isRefractionEnabled),
      isVeilEnabled: \(tuning.isVeilEnabled),
      isSpecularEnabled: \(tuning.isSpecularEnabled),
      isRimLightingEnabled: \(tuning.isRimLightingEnabled)
    )
    """
  }
}

// MARK: - Xcode Preview

#Preview {
  LiquidGlassPlaygroundView()
}
