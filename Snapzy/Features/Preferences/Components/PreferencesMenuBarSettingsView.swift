//
//  PreferencesMenuBarSettingsView.swift
//  Snapzy
//
//  Menu Bar preferences tab: menu item visibility and order.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let menuBarItemReorder = UTType("com.snapzy.menu-bar-reorder") ?? .text
}

struct MenuBarSettingsView: View {
  @ObservedObject private var store = MenuBarCustomizationStore.shared
  @State private var draggedItem: MenuBarItemKind?
  @State private var activeDragID: UUID?
  @State private var mouseUpMonitor: Any?

  var body: some View {
    Form {
      ForEach(MenuBarItemGroup.allCases, id: \.self) { group in
        itemGroupSection(group)
      }

      Section(L10n.PreferencesMenuBar.appSection) {
        SettingRow(
          icon: MenuBarItemKind.checkForUpdates.systemImage,
          title: MenuBarItemKind.checkForUpdates.settingsTitle,
          description: nil
        ) {
          Toggle("", isOn: Binding(
            get: { !store.isHidden(.checkForUpdates) },
            set: { store.setHidden(.checkForUpdates, hidden: !$0) }
          ))
          .labelsHidden()
        }
      }

      Section {
        HStack {
          Spacer()
          Button(L10n.PreferencesMenuBar.resetButton) {
            store.resetToDefaults()
          }
          .buttonStyle(.bordered)
          .controlSize(.regular)
        }
      } footer: {
        Text(L10n.PreferencesMenuBar.itemsDescription)
      }
    }
    .formStyle(.grouped)
  }

  // MARK: - Item Group Section

  private func itemGroupSection(_ group: MenuBarItemGroup) -> some View {
    Section(itemGroupTitle(group)) {
      VStack(spacing: 0) {
        ForEach(Array(store.orderedItems(for: group).enumerated()), id: \.element.rawValue) { index, item in
          MenuBarItemRow(
            item: item,
            index: index,
            group: group,
            store: store,
            isVisible: Binding(
              get: { !store.isHidden(item) },
              set: { store.setHidden(item, hidden: !$0) }
            ),
            draggedItem: $draggedItem,
            activeDragID: $activeDragID
          )

          if index < store.orderedItems(for: group).count - 1 {
            Divider()
          }
        }
      }
      .padding(.vertical, 4)
      .onAppear {
        mouseUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { event in
          if self.draggedItem != nil {
            self.draggedItem = nil
          }
          if self.activeDragID != nil {
            self.activeDragID = nil
          }
          return event
        }
      }
      .onDisappear {
        if let monitor = mouseUpMonitor {
          NSEvent.removeMonitor(monitor)
          mouseUpMonitor = nil
        }
      }
    }
  }

  private func itemGroupTitle(_ group: MenuBarItemGroup) -> String {
    switch group {
    case .capture: return L10n.PreferencesMenuBar.captureSection
    case .recording: return L10n.PreferencesMenuBar.recordingSection
    case .tools: return L10n.PreferencesMenuBar.toolsSection
    }
  }
}

// MARK: - Item Row

private struct MenuBarItemRow: View {
  let item: MenuBarItemKind
  let index: Int
  let group: MenuBarItemGroup
  let store: MenuBarCustomizationStore
  @Binding var isVisible: Bool
  @Binding var draggedItem: MenuBarItemKind?
  @Binding var activeDragID: UUID?
  @State private var isHandleHovered = false

  var body: some View {
    HStack(spacing: 10) {
      // Drag handle — reorder within the group only
      Image(systemName: "line.3.horizontal")
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(isHandleHovered ? .secondary : .quaternary)
        .frame(width: 14)
        .contentShape(Rectangle().inset(by: -4))
        .onHover { isHandleHovered = $0 }
        .onDrag {
          let dragID = UUID()
          self.activeDragID = dragID
          self.draggedItem = item

          let provider = MenuBarDragTrackingItemProvider()
          if let data = item.rawValue.data(using: .utf8) {
            provider.registerDataRepresentation(
              forTypeIdentifier: UTType.menuBarItemReorder.identifier,
              visibility: .all
            ) { completion in
              completion(data, nil)
              return nil
            }
          }

          provider.onDeinit = { [dragID] in
            Task { @MainActor in
              if self.activeDragID == dragID {
                self.activeDragID = nil
                self.draggedItem = nil
              }
            }
          }
          return provider
        } preview: {
          // No visual ghost — handle-drag is a reorder-only gesture.
          Color.clear.frame(width: 1, height: 1)
        }

      Image(systemName: item.systemImage)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.secondary)
        .frame(width: 18)

      Text(item.settingsTitle)
        .lineLimit(1)

      Spacer()

      Toggle("", isOn: $isVisible)
        .labelsHidden()
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .opacity(isVisible ? 1.0 : 0.6)
    .background(draggedItem == item ? Color(NSColor.selectedControlColor).opacity(0.15) : Color.clear)
    .onDrop(of: [UTType.menuBarItemReorder], delegate: MenuBarReorderDropDelegate(
      targetItem: item,
      targetIndex: index,
      group: group,
      store: store,
      draggedItem: $draggedItem
    ))
  }
}

private struct MenuBarReorderDropDelegate: DropDelegate {
  let targetItem: MenuBarItemKind
  let targetIndex: Int
  let group: MenuBarItemGroup
  let store: MenuBarCustomizationStore
  @Binding var draggedItem: MenuBarItemKind?

  func validateDrop(info: DropInfo) -> Bool {
    draggedItem != nil
  }

  func dropEntered(info: DropInfo) {
    guard let sourceItem = draggedItem,
          sourceItem != targetItem else { return }

    let groupItems = store.orderedItems(for: group)
    guard let sourceIndex = groupItems.firstIndex(of: sourceItem) else { return }

    if sourceIndex != targetIndex {
      withAnimation(.default) {
        store.moveItem(
          from: IndexSet(integer: sourceIndex),
          to: targetIndex > sourceIndex ? targetIndex + 1 : targetIndex,
          in: group
        )
      }
    }
  }

  func performDrop(info: DropInfo) -> Bool {
    Task { @MainActor in
      draggedItem = nil
    }
    return true
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }
}

private final class MenuBarDragTrackingItemProvider: NSItemProvider {
  var onDeinit: (() -> Void)?
  deinit {
    onDeinit?()
  }
}

#Preview {
  MenuBarSettingsView()
    .frame(width: 600, height: 500)
}
