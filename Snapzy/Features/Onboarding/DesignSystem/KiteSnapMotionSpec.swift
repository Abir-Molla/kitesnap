//
//  KiteSnapMotionSpec.swift
//  Snapzy
//
//  Motion and animation token specifications with macOS 13+ backward compatibility.
//

import AppKit
import SwiftUI

struct KiteSnapMotionSpec: Equatable {
  var duration: Double
  var curve: Curve

  enum Curve: Equatable {
    case custom(Double, Double, Double, Double)
    case spring(bounce: Double)
    case easeInOut
    case easeOut
    case easeIn
    case linear
  }

  var animation: Animation {
    switch curve {
    case .custom(let a, let b, let c, let d):
      return .timingCurve(a, b, c, d, duration: duration)
    case .spring(let bounce):
      if #available(macOS 14.0, *) {
        return .spring(duration: duration, bounce: bounce)
      } else {
        let dampingFraction = 1.0 - (bounce * 0.5)
        return .spring(response: duration, dampingFraction: dampingFraction)
      }
    case .easeInOut:
      return .easeInOut(duration: duration)
    case .easeOut:
      return .easeOut(duration: duration)
    case .easeIn:
      return .easeIn(duration: duration)
    case .linear:
      return .linear(duration: duration)
    }
  }

  func respectingReduceMotion(_ reduce: Bool) -> KiteSnapMotionSpec {
    reduce ? KiteSnapMotionSpec(duration: 0, curve: .linear) : self
  }

  var timingFunction: CAMediaTimingFunction? {
    switch curve {
    case .custom(let a, let b, let c, let d):
      return CAMediaTimingFunction(controlPoints: Float(a), Float(b), Float(c), Float(d))
    case .easeInOut:
      return CAMediaTimingFunction(name: .easeInEaseOut)
    case .easeOut:
      return CAMediaTimingFunction(name: .easeOut)
    case .easeIn:
      return CAMediaTimingFunction(name: .easeIn)
    case .linear:
      return CAMediaTimingFunction(name: .linear)
    case .spring:
      return nil
    }
  }

  // MARK: - Named Vocabulary

  static let morph = KiteSnapMotionSpec(duration: 0.42, curve: .spring(bounce: 0.45))
  static let anticipation = KiteSnapMotionSpec(duration: 0.13, curve: .easeOut)
  static let glide = KiteSnapMotionSpec(duration: 0.45, curve: .custom(0.22, 0.9, 0.24, 1))
  static let contentIn = KiteSnapMotionSpec(duration: 0.22, curve: .easeOut)
  static let contentOut = KiteSnapMotionSpec(duration: 0.12, curve: .easeIn)
  static let hover = KiteSnapMotionSpec(duration: 0.12, curve: .easeOut)
  static let settle = KiteSnapMotionSpec(duration: 0.4, curve: .spring(bounce: 0.22))
  static let instant = KiteSnapMotionSpec(duration: 0, curve: .linear)
}

@MainActor
final class KiteSnapMotionPreferences {
  static let shared = KiteSnapMotionPreferences()

  var reduceMotion: Bool {
    NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
  }

  func spec(_ base: KiteSnapMotionSpec) -> KiteSnapMotionSpec {
    base.respectingReduceMotion(reduceMotion)
  }
}
