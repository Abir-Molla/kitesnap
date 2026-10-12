//
//  AppIconProvider.swift
//  Snapzy
//
//  Provides reliable access to KiteSnap's application icon.
//

import AppKit
import SwiftUI

enum AppIconProvider {
  static var image: NSImage {
    if let assetImage = NSImage(named: "AppIconImage") {
      return assetImage
    }
    if let icnsURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
       let img = NSImage(contentsOf: icnsURL) {
      return img
    }
    return NSApp.applicationIconImage
  }
}
