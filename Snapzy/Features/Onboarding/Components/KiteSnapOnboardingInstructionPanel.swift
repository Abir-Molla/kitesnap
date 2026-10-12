//
//  KiteSnapOnboardingInstructionPanel.swift
//  Snapzy
//
//  Left-column instruction panel carrying narrative, challenge checklist, and simulation prompt card.
//

import SwiftUI

struct KiteSnapOnboardingInstructionPanel: View {
  @ObservedObject var state: KiteSnapOnboardingState

  private var activeChallenge: KiteSnapOnboardingChallenge? {
    state.currentStep.challenges.first { !state.completedChallenges.contains($0) }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      headline

      challengeChecklist

      if !state.currentStep.examplePrompt.isEmpty {
        promptCard
      }

      if !state.currentStep.tip.isEmpty {
        tip
      }

      Spacer(minLength: 0)
    }
    .frame(width: KiteSnapOnboardingMetrics.railWidth, alignment: .leading)
  }

  // MARK: - Headline

  private var headline: some View {
    VStack(alignment: .leading, spacing: KiteSnapSpace.xxl) {
      KiteSnapOnboardingOverline(L10n.Onboarding.stepIndicator(state.currentStep.stepNumber, KiteSnapOnboardingStep.allCases.count))

      Text(state.currentStep.title)
        .font(.system(size: KiteSnapOnboardingType.display, weight: .bold))
        .tracking(-0.6)
        .foregroundStyle(KiteSnapGlassInk.primary)
        .fixedSize(horizontal: false, vertical: true)

      Text(state.currentStep.subtitle)
        .font(.system(size: KiteSnapOnboardingType.lede))
        .foregroundStyle(KiteSnapGlassInk.body)
        .lineSpacing(6)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  // MARK: - Checklist

  private var challengeChecklist: some View {
    VStack(alignment: .leading, spacing: KiteSnapSpace.xxl - KiteSnapSpace.xxs) {
      ForEach(state.currentStep.challenges) { challenge in
        ChallengeRow(
          challenge: challenge,
          isDone: state.completedChallenges.contains(challenge),
          isActive: activeChallenge == challenge
        )
      }
    }
    .animation(KiteSnapMotionPreferences.shared.spec(.settle).animation, value: state.completedChallenges)
  }

  // MARK: - Prompt Card

  private var promptText: String {
    if state.currentStep == .meetSnapzy {
      switch state.step1Stage {
      case .readyToCapture:
        return L10n.Onboarding.stepCapturePromptReady
      case .selectingArea:
        return L10n.Onboarding.stepCapturePromptSelecting
      case .quickAccessFloating:
        return L10n.Onboarding.stepCapturePromptFloating
      case .annotateWindowOpen:
        return L10n.Onboarding.stepCapturePromptOpen
      }
    } else if state.currentStep == .quickAccess {
      switch state.step2Stage {
      case .readyToRecord:
        return L10n.Onboarding.stepRecordingPromptReady
      case .prerecordArea:
        return L10n.Onboarding.stepRecordingPromptFramed
      case .recordingActive:
        return L10n.Onboarding.stepRecordingPromptActive(state.recordingSeconds)
      case .videoQuickAccess:
        return L10n.Onboarding.stepRecordingPromptFloating
      }
    } else if state.currentStep == .shortcuts {
      if state.hasConflict {
        return L10n.Onboarding.stepShortcutsPromptConflicts
      } else {
        return L10n.Onboarding.stepShortcutsPromptResolved
      }
    }
    return state.currentStep.examplePrompt
  }

  private var promptCard: some View {
    Button {
      switch state.currentStep {
      case .meetSnapzy:
        switch state.step1Stage {
        case .readyToCapture:
          state.simulateAreaCapture()
        case .selectingArea:
          state.completeCaptureToQuickAccess()
        case .quickAccessFloating:
          state.openAnnotateFromQuickAccess()
        case .annotateWindowOpen:
          state.resetStep1Flow()
        }
      case .quickAccess:
        switch state.step2Stage {
        case .readyToRecord:
          state.simulateStartPrerecord()
        case .prerecordArea:
          state.simulateStartRecording()
        case .recordingActive:
          state.simulateFinishRecording()
        case .videoQuickAccess:
          state.resetStep2Flow()
        }
      case .shortcuts:
        state.resolveShortcutConflicts()
      case .permissions:
        break
      }
    } label: {
      VStack(alignment: .leading, spacing: KiteSnapSpace.lg) {
        KiteSnapOnboardingOverline(L10n.Onboarding.demoOverline, tint: KiteSnapGlassInk.muted)

        Text(promptText)
          .font(.system(size: KiteSnapOnboardingType.lede - 0.5).italic())
          .foregroundStyle(KiteSnapGlassInk.primary.opacity(0.94))
          .multilineTextAlignment(.leading)
          .lineSpacing(4)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, KiteSnapSpace.xxl + KiteSnapSpace.xs)
      .padding(.vertical, KiteSnapSpace.xxl)
      .background(
        Radius.rect(KiteSnapRadius.card)
          .fill(Color.white.opacity(0.07))
          .overlay(
            Radius.rect(KiteSnapRadius.card)
              .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
          )
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(KiteSnapPromptCardButtonStyle())
    .help(L10n.Onboarding.demoTooltip)
  }

  // MARK: - Tip

  private var tip: some View {
    HStack(alignment: .top, spacing: KiteSnapSpace.lg) {
      Image(systemName: "info.circle")
        .font(.system(size: 12))
        .foregroundStyle(KiteSnapGlassInk.faint)

      Text(state.currentStep.tip)
        .font(.system(size: KiteSnapOnboardingType.caption))
        .foregroundStyle(KiteSnapGlassInk.muted)
        .lineSpacing(3)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

// MARK: - Challenge Row

private struct ChallengeRow: View {
  var challenge: KiteSnapOnboardingChallenge
  var isDone: Bool
  var isActive: Bool

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: KiteSnapSpace.xxl) {
      marker
        .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 5 }

      Text(challenge.label)
        .font(.system(size: KiteSnapOnboardingType.challenge, weight: isActive ? .semibold : .regular))
        .foregroundStyle(labelInk)
        .lineSpacing(3)
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: KiteSnapSpace.md)

      if !challenge.keys.isEmpty {
        KiteSnapKeycapRow(keys: challenge.keys, emphasis: isActive)
          .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 5 }
      }
    }
  }

  private var labelInk: Color {
    if isActive { return KiteSnapGlassInk.primary }
    if isDone { return KiteSnapGlassInk.body }
    return KiteSnapGlassInk.muted
  }

  @ViewBuilder
  private var marker: some View {
    ZStack {
      if isDone {
        Circle().fill(Color.accentColor)
        Image(systemName: "checkmark")
          .font(.system(size: 9, weight: .bold))
          .foregroundStyle(.white)
      } else {
        Circle()
          .strokeBorder(
            Color.white.opacity(isActive ? 0.75 : 0.24),
            lineWidth: isActive ? 1.5 : 1
          )
      }
    }
    .frame(width: 20, height: 20)
  }
}

private struct KiteSnapPromptCardButtonStyle: ButtonStyle {
  @State private var isHovered = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay(
        Radius.rect(KiteSnapRadius.card)
          .fill(Color.white.opacity(configuration.isPressed ? 0.06 : (isHovered ? 0.04 : 0)))
      )
      .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
      .onHover { hovering in
        withAnimation(KiteSnapMotionPreferences.shared.spec(.hover).animation) { isHovered = hovering }
      }
      .animation(.spring(response: 0.18, dampingFraction: 0.8), value: configuration.isPressed)
  }
}
