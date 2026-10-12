//
//  KiteSnapOnboardingStepRail.swift
//  Snapzy
//
//  Progress rail across the onboarding header, matching Ruru's step indicator design.
//

import SwiftUI

struct KiteSnapOnboardingStepRail: View {
  @ObservedObject var state: KiteSnapOnboardingState

  var body: some View {
    HStack(spacing: 0) {
      ForEach(Array(KiteSnapOnboardingStep.allCases.enumerated()), id: \.element) { index, step in
        if index > 0 {
          connector(leadingInto: step)
        }
        node(for: step)
      }
    }
    .animation(KiteSnapMotionPreferences.shared.spec(.settle).animation, value: state.currentStep)
  }

  // MARK: - Node

  private func node(for step: KiteSnapOnboardingStep) -> some View {
    let isCurrent = state.currentStep == step
    let isVisited = state.completedSteps.contains(step)
    let isReachable = isVisited || step.stepNumber <= state.currentStep.stepNumber

    return Button {
      guard isReachable else { return }
      state.transition(to: step)
    } label: {
      HStack(spacing: KiteSnapSpace.md) {
        marker(number: step.stepNumber, isCurrent: isCurrent, isVisited: isVisited)

        Text(step.shortTitle)
          .font(.system(size: KiteSnapOnboardingType.caption, weight: isCurrent ? .semibold : .medium))
          .foregroundStyle(isCurrent ? KiteSnapGlassInk.primary : KiteSnapGlassInk.muted)
          .fixedSize()
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(!isReachable)
    .help(isReachable ? "Go to \(step.shortTitle)" : "")
  }

  private func marker(number: Int, isCurrent: Bool, isVisited: Bool) -> some View {
    ZStack {
      Circle()
        .fill(Color.white.opacity(isCurrent ? 0.18 : 0.04))
        .overlay(
          Circle().strokeBorder(
            Color.white.opacity(isCurrent ? 0.85 : 0.22),
            lineWidth: isCurrent ? 1.2 : 1
          )
        )

      if isVisited && !isCurrent {
        Image(systemName: "checkmark")
          .font(.system(size: 9.5, weight: .bold))
          .foregroundStyle(KiteSnapGlassInk.body)
      } else {
        Text("\(number)")
          .font(.system(size: 11, weight: isCurrent ? .bold : .medium))
          .foregroundStyle(isCurrent ? KiteSnapGlassInk.primary : KiteSnapGlassInk.muted)
      }
    }
    .frame(width: 24, height: 24)
  }

  // MARK: - Connector

  private func connector(leadingInto step: KiteSnapOnboardingStep) -> some View {
    let isTraversed = step.stepNumber <= state.currentStep.stepNumber

    return Rectangle()
      .fill(Color.white.opacity(isTraversed ? 0.28 : 0.12))
      .frame(width: 26, height: 1)
      .padding(.horizontal, KiteSnapSpace.xl)
  }
}
