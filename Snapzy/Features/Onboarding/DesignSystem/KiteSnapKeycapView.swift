//
//  KiteSnapKeycapView.swift
//  Snapzy
//
//  Physical Mac keycap chip and row components for keyboard shortcut display.
//

import SwiftUI

struct KiteSnapKeycapChip: View {
  var label: String
  var emphasis: Bool = false

  private var height: CGFloat { 19 }

  var body: some View {
    Text(label)
      .font(.system(size: KiteSnapOnboardingType.keycap + 1, weight: .semibold, design: .rounded))
      .foregroundStyle(emphasis ? KiteSnapGlassInk.primary : KiteSnapGlassInk.muted)
      .padding(.horizontal, 5.5)
      .frame(minWidth: height, minHeight: height)
      .background {
        ZStack {
          Radius.rect(Radius.ornament)
            .fill(Color.black.opacity(0.24))

          Radius.rect(Radius.ornament)
            .fill(Color.white.opacity(emphasis ? 0.20 : 0.08))

          Radius.rect(Radius.ornament)
            .strokeBorder(
              LinearGradient(
                colors: [
                  Color.white.opacity(emphasis ? 0.36 : 0.16),
                  Color.white.opacity(emphasis ? 0.10 : 0.04),
                ],
                startPoint: .top,
                endPoint: .bottom
              ),
              lineWidth: KiteSnapSurfaceGlass.specularLineWidth
            )
        }
      }
      .fixedSize()
  }
}

struct KiteSnapKeycapRow: View {
  var keys: [String]
  var emphasis: Bool = false

  var body: some View {
    HStack(spacing: 3) {
      ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
        KiteSnapKeycapChip(label: key, emphasis: emphasis)
      }
    }
  }
}
