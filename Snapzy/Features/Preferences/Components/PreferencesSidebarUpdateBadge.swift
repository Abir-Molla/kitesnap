//
//  PreferencesSidebarUpdateBadge.swift
//  Snapzy
//
//  Sidebar bottom badge showing KiteSnap icon, name, version, and quick update action.
//

import AppKit
import Sparkle
import SwiftUI

struct PreferencesSidebarUpdateBadge: View {
  @State private var isHovering = false
  @State private var showUpToDateAlert = false

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    return "v\(version)"
  }

  var body: some View {
    VStack(spacing: 0) {
      Divider()
        .opacity(0.4)

      Button {
        triggerUpdateCheck()
      } label: {
        HStack(spacing: 10) {
          Image(nsImage: AppIconProvider.image)
            .resizable()
            .scaledToFit()
            .frame(width: 28, height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
              RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
            )

          VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
              Text(verbatim: "KiteSnap")
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(.primary)

              Spacer(minLength: 4)

              upToDateBadge
            }

            Text(appVersion)
              .font(.system(size: 10.5))
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background {
          Radius.rect(Radius.card)
            .fill(isHovering ? Color.primary.opacity(0.06) : Color.primary.opacity(0.035))
        }
        .overlay {
          Radius.rect(Radius.card)
            .strokeBorder(isHovering ? Color.primary.opacity(0.1) : Color.primary.opacity(0.06), lineWidth: 1)
        }
        .contentShape(Radius.rect(Radius.card))
      }
      .buttonStyle(.plain)
      .onHover { hovering in
        isHovering = hovering
      }
      .help(L10n.Menu.checkForUpdates)
      .contextMenu {
        Button(L10n.Menu.checkForUpdates) {
          triggerUpdateCheck()
        }

        Divider()

        Button(L10n.Preferences.aboutTab) {
          PreferencesNavigationState.shared.select(.about)
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 8)
    }
    .alert(isPresented: $showUpToDateAlert) {
      Alert(
        title: Text("KiteSnap is Up to Date"),
        message: Text("You are using the latest version of KiteSnap (\(appVersion))."),
        dismissButton: .default(Text(L10n.Common.ok))
      )
    }
  }

  private var upToDateBadge: some View {
    Text("LATEST")
      .font(.system(size: 9.0, weight: .bold))
      .padding(.horizontal, 4.5)
      .padding(.vertical, 1.5)
      .foregroundStyle(Color.green)
      .background(
        Capsule()
          .fill(Color.green.opacity(0.15))
      )
  }

  private func triggerUpdateCheck() {
    showUpToDateAlert = true
    UpdaterManager.shared.checkForUpdates()
  }
}

#Preview {
  PreferencesSidebarUpdateBadge()
    .frame(width: 200)
}
