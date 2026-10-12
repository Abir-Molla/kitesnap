//
//  KiteSnapOnboardingChrome.swift
//  Snapzy
//
//  Header brand mark, language selector, close button, and footer escape affordance.
//

import AppKit
import SwiftUI

// MARK: - Overline

struct KiteSnapOnboardingOverline: View {
  var text: String
  var tint: Color = KiteSnapGlassInk.muted

  init(_ text: String, tint: Color = KiteSnapGlassInk.muted) {
    self.text = text
    self.tint = tint
  }

  var body: some View {
    Text(text.uppercased())
      .font(.system(size: KiteSnapOnboardingType.sectionLabel, weight: .semibold))
      .tracking(1.3)
      .foregroundStyle(tint)
  }
}

// MARK: - Close Button

struct KiteSnapOnboardingCloseButton: View {
  var action: () -> Void

  @State private var isHovered = false

  var body: some View {
    Button(action: action) {
      Image(systemName: "xmark")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(isHovered ? KiteSnapGlassInk.primary : KiteSnapGlassInk.muted)
        .frame(width: 28, height: 28)
        .background(
          Circle()
            .fill(Color.white.opacity(isHovered ? 0.16 : 0.08))
            .overlay(Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5))
        )
    }
    .buttonStyle(.plain)
    .onHover { hovering in
      withAnimation(KiteSnapMotionPreferences.shared.spec(.hover).animation) {
        isHovered = hovering
      }
    }
    .accessibilityLabel(L10n.Onboarding.chromeCloseAccessibility)
  }
}

// MARK: - Language Picker Pill

struct KiteSnapOnboardingLanguagePicker: View {
  @EnvironmentObject private var onboardingLocalization: OnboardingLocalizationController

  var body: some View {
    Menu {
      Button {
        onboardingLocalization.selectLanguage("")
      } label: {
        HStack {
          Text(L10n.Onboarding.chromeLanguageAutoSystem)
          if onboardingLocalization.selectedLanguageIdentifier.isEmpty {
            Image(systemName: "checkmark")
          }
        }
      }

      Divider()

      ForEach(onboardingLocalization.availableOptions) { option in
        Button {
          onboardingLocalization.selectLanguage(option.identifier)
        } label: {
          HStack {
            Text(option.displayName)
            if onboardingLocalization.selectedLanguageIdentifier == option.identifier {
              Image(systemName: "checkmark")
            }
          }
        }
      }
    } label: {
      HStack(spacing: KiteSnapSpace.sm) {
        Image(systemName: "globe")
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(KiteSnapGlassInk.muted)

        Text(currentLanguageLabel)
          .font(.system(size: KiteSnapOnboardingType.caption, weight: .medium))
          .foregroundStyle(KiteSnapGlassInk.body)

        Image(systemName: "chevron.down")
          .font(.system(size: 8, weight: .semibold))
          .foregroundStyle(KiteSnapGlassInk.muted)
      }
      .padding(.horizontal, KiteSnapSpace.lg)
      .frame(height: 28)
      .background(
        Capsule(style: .continuous)
          .fill(Color.white.opacity(0.08))
          .overlay(Capsule(style: .continuous).strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5))
      )
    }
    .menuStyle(.borderlessButton)
    .fixedSize()
  }

  private var currentLanguageLabel: String {
    if onboardingLocalization.selectedLanguageIdentifier.isEmpty {
      return onboardingLocalization.systemResolvedOption?.displayName ?? L10n.Onboarding.chromeLanguageAuto
    }
    return onboardingLocalization.availableOptions.first(where: { $0.identifier == onboardingLocalization.selectedLanguageIdentifier })?.displayName ?? L10n.Onboarding.chromeLanguageLabel
  }
}

// MARK: - Escape Hint

struct KiteSnapOnboardingEscapeHint: View {
  var text: String

  var body: some View {
    HStack(spacing: KiteSnapSpace.md) {
      KiteSnapKeycapChip(label: "esc")
      Text(text)
        .font(.system(size: KiteSnapOnboardingType.caption))
        .foregroundStyle(KiteSnapGlassInk.muted)
    }
  }
}
