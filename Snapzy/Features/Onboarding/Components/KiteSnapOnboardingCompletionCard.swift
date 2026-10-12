//
//  KiteSnapOnboardingCompletionCard.swift
//  Snapzy
//
//  Celebratory completion view with Dark Liquid Glass aesthetics, clean logo presentation,
//  monochrome capability cards showcase, ecosystem links, and consistent action bar button.
//

import AppKit
import SwiftUI

struct KiteSnapOnboardingCompletionCard: View {
  var onFinish: () -> Void
  var onBack: (() -> Void)? = nil

  @State private var hasAppeared = false

  var body: some View {
    VStack(spacing: 22) {
      Spacer(minLength: 8)

      // 1. Clean Logo (no border, no check, no shadow)
      heroLogo
        .opacity(hasAppeared ? 1 : 0)

      // 2. Headline & Description (monochrome simple palette)
      headerSection
        .opacity(hasAppeared ? 1 : 0)

      // 3. Core Capabilities (monochrome 4-card glass grid)
      capabilitiesGrid
        .opacity(hasAppeared ? 1 : 0)

      // 4. Primary Action Button (same style as previous onboarding steps)
      primaryActionRow
        .opacity(hasAppeared ? 1 : 0)

      Spacer(minLength: 8)
    }
    .frame(maxWidth: 900)
    .onAppear {
      withAnimation(KiteSnapMotionPreferences.shared.spec(.morph).animation) {
        hasAppeared = true
      }
    }
  }

  // MARK: - Hero Logo

  private var heroLogo: some View {
    Image(nsImage: NSApp.applicationIconImage)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 56, height: 56)
      .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous)) // radius-lint:allow — clips the app icon bitmap; matches the icon's own corner
  }

  // MARK: - Header Section

  private var headerSection: some View {
    VStack(spacing: 8) {
      KiteSnapOnboardingOverline(L10n.Onboarding.completionCardOverline)

      Text(L10n.Onboarding.completionCardTitle)
        .font(.system(size: 28, weight: .bold))
        .tracking(-0.5)
        .foregroundStyle(KiteSnapGlassInk.primary)

      Text(L10n.Onboarding.completionCardSubtitle)
        .font(.system(size: KiteSnapOnboardingType.lede))
        .foregroundStyle(KiteSnapGlassInk.body)
        .multilineTextAlignment(.center)
        .lineSpacing(3)
        .frame(maxWidth: 580)
    }
  }

  // MARK: - Capabilities Grid

  private var capabilitiesGrid: some View {
    HStack(spacing: 12) {
      CapabilityCard(
        icon: "camera.viewfinder",
        shortcut: "⇧⌘4",
        title: L10n.Onboarding.completionAreaCaptureTitle,
        detail: L10n.Onboarding.completionAreaCaptureDetail
      )

      CapabilityCard(
        icon: "record.circle",
        shortcut: "⇧⌘5",
        title: L10n.Onboarding.completionScreenRecordingTitle,
        detail: L10n.Onboarding.completionScreenRecordingDetail
      )

      CapabilityCard(
        icon: "text.viewfinder",
        shortcut: "⇧⌘2",
        title: L10n.Onboarding.completionOcrTitle,
        detail: L10n.Onboarding.completionOcrDetail
      )

      CapabilityCard(
        icon: "menubar.rectangle",
        shortcut: "⌘,",
        title: L10n.Onboarding.completionMenubarHubTitle,
        detail: L10n.Onboarding.completionMenubarHubDetail
      )
    }
    .frame(maxWidth: 880)
  }

  // MARK: - Primary Action

  private var primaryActionRow: some View {
    VStack(spacing: 10) {
      KiteSnapOnboardingActionBar(
        continueTitle: L10n.Onboarding.completionStartUsing,
        continueKey: "\u{21A9}",
        isContinueEnabled: true,
        onContinue: onFinish
      )

      if let onBack {
        Button(action: onBack) {
          Text(L10n.Onboarding.completionReviewHint)
            .font(.system(size: 11))
            .foregroundStyle(KiteSnapGlassInk.faint)
        }
        .buttonStyle(.plain)
      }
    }
  }
}

// MARK: - Capability Card

private struct CapabilityCard: View {
  var icon: String
  var shortcut: String
  var title: String
  var detail: String

  @State private var isHovered = false

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        // Monochrome glass icon container matching previous steps
        Image(systemName: icon)
          .font(.system(size: 13))
          .foregroundStyle(KiteSnapGlassInk.body)
          .frame(width: 26, height: 26)
          .background(
            Radius.rect(Radius.tile)
              .fill(Color.white.opacity(0.08))
          )

        Spacer(minLength: 0)

        KiteSnapKeycapChip(label: shortcut, emphasis: isHovered)
      }

      Text(title)
        .font(.system(size: 12.5, weight: .semibold))
        .foregroundStyle(KiteSnapGlassInk.primary)

      Text(detail)
        .font(.system(size: 11))
        .foregroundStyle(KiteSnapGlassInk.muted)
        .lineSpacing(2)
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 0)
    }
    .padding(14)
    .frame(maxWidth: .infinity, minHeight: 122, alignment: .topLeading)
    .background(
      Radius.rect(KiteSnapRadius.card)
        .fill(Color.white.opacity(isHovered ? 0.065 : 0.04))
        .overlay(
          Radius.rect(KiteSnapRadius.card)
            .strokeBorder(
              Color.white.opacity(isHovered ? 0.16 : 0.08),
              lineWidth: 0.5
            )
        )
    )
    .onHover { hovering in
      withAnimation(KiteSnapMotionPreferences.shared.spec(.hover).animation) {
        isHovered = hovering
      }
    }
  }
}

