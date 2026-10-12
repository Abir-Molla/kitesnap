//
//  PreferencesAboutSettingsView.swift
//  Snapzy
//
//  Redesigned About tab following clean, card-based Hand Mirror aesthetic.
//

import AppKit
import SwiftUI

struct AboutSettingsView: View {

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "KiteSnap \(version) (\(build))"
  }

  @StateObject private var updatesViewModel = CheckForUpdatesViewModel(updater: UpdaterManager.shared.updater)
  @State private var showUpToDateAlert = false

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 20) {
          // Hero Icon & Title
          heroSection

          // Card 1: Attribution & Special thanks
          attributionCard

          // Card 2: Updates & Support
          versionAndSupportCard

          Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, minHeight: proxy.size.height)
        .padding(.horizontal, 28)
        .padding(.top, 28)
        .padding(.bottom, 28)
      }
    }
    .alert(isPresented: $showUpToDateAlert) {
      Alert(
        title: Text("KiteSnap is Up to Date"),
        message: Text("You are using the latest version of KiteSnap (\(appVersion))."),
        dismissButton: .default(Text(L10n.Common.ok))
      )
    }
  }

  // MARK: - Hero Section

  private var heroSection: some View {
    VStack(spacing: 10) {
      Image(nsImage: AppIconProvider.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 96, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)) // radius-lint:allow — clips the app icon bitmap; matches the icon's own corner
        .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)

      VStack(spacing: 3) {
        Text(verbatim: "KiteSnap")
          .font(.system(size: 24, weight: .bold, design: .rounded))
          .foregroundStyle(Color.primary)

        Text(L10n.PreferencesAbout.appSubtitle)
          .font(.subheadline)
          .foregroundStyle(Color.secondary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .frame(maxWidth: 420)
      }

      VStack(spacing: 10) {
        versionStatusLabel

        Button {
          showUpToDateAlert = true
          updatesViewModel.checkForUpdates()
        } label: {
          HStack(spacing: 5) {
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(.system(size: 11, weight: .semibold))
            Text(L10n.PreferencesAbout.checkForUpdates)
          }
        }
        .buttonStyle(.liquidGlass(emphasis: .primary, capsule: true))
        .help(updatesViewModel.lastUpdateCheckDate
          .map { "\(L10n.PreferencesAbout.checkedLabel): \($0.formatted(date: .abbreviated, time: .shortened))" } ??
          L10n.PreferencesAbout.checkForUpdates)
      }
      .padding(.top, 6)
    }
    .padding(.bottom, 4)
  }

  private var versionStatusLabel: some View {
    HStack(spacing: 6) {
      Text(appVersion)
        .font(.system(size: 11, weight: .regular))
        .foregroundStyle(Color.secondary)

      if let lastCheck = updatesViewModel.lastUpdateCheckDate {
        Text("•")
          .font(.system(size: 10))
          .foregroundStyle(Color.secondary.opacity(0.5))

        HStack(spacing: 3) {
          Text(L10n.PreferencesAbout.checkedLabel)
          Text(lastCheck, style: .relative)
        }
        .font(.system(size: 11, weight: .regular))
        .foregroundStyle(Color.secondary)
      }
    }
  }

  // MARK: - Card 1: Attribution & Special Thanks

  private var attributionCard: some View {
    VStack(spacing: 0) {
      // Made by
      HStack(alignment: .center) {
        Text(L10n.PreferencesAbout.madeBy)
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(Color.primary)

        Spacer()

        Link(destination: URL(string: "https://github.com/Abir-Molla/kitesnap")!) {
          Text("Abir Molla")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.primary)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

    }
    .cardContainer(maxWidth: 480)
  }

  // MARK: - Card 2: Version & Support

  private var versionAndSupportCard: some View {
    VStack(spacing: 0) {
      // Support & Links
      HStack(alignment: .top) {
        Text(L10n.PreferencesAbout.support)
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(Color.primary)

        Spacer(minLength: 20)

        VStack(alignment: .trailing, spacing: 8) {
          supportLink(title: L10n.PreferencesAbout.github, url: "https://github.com/Abir-Molla/kitesnap")
          supportLink(title: L10n.PreferencesAbout.reportBug, url: "https://github.com/Abir-Molla/kitesnap/issues")
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
    }
    .cardContainer(maxWidth: 480)
  }

  // MARK: - Helpers

  private var divider: some View {
    Rectangle()
      .fill(Color.primary.opacity(0.08))
      .frame(height: 0.5)
      .padding(.horizontal, 12)
  }

  private func supportLink(title: String, url: String, isHighlighted: Bool = false) -> some View {
    Link(destination: URL(string: url)!) {
      HStack(spacing: 4) {
        Text(title)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(isHighlighted ? Color.red.opacity(0.9) : Color.accentColor)

        Image(systemName: "arrow.up.right")
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(isHighlighted ? Color.red.opacity(0.8) : Color.accentColor.opacity(0.8))
      }
    }
    .buttonStyle(.plain)
  }

}

private extension View {
  func cardContainer(maxWidth: CGFloat) -> some View {
    background {
      Radius.rect(Radius.card)
        .fill(Color.primary.opacity(0.04))
    }
    .clipShape(Radius.rect(Radius.card))
    .frame(maxWidth: maxWidth)
  }
}

#Preview {
  AboutSettingsView()
    .frame(width: 700, height: 600)
}
