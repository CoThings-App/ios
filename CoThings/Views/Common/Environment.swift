//
//  Environment.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/09.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct HostingWindowKey: EnvironmentKey {
#if canImport(UIKit)
    typealias WrappedValue = UIWindow
#elseif canImport(AppKit)
    typealias WrappedValue = NSWindow
#else
#error("Unsupported platform")
#endif

    typealias Value = () -> WrappedValue? // needed for weak link
    static let defaultValue: Self.Value = { nil }
}

#if canImport(UIKit)
struct StatusBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}
#endif

extension EnvironmentValues {
    var hostingWindow: HostingWindowKey.Value {
        get {
            return self[HostingWindowKey.self]
        }
        set {
            self[HostingWindowKey.self] = newValue
        }
    }

#if canImport(UIKit)
    var statusBarHeight: StatusBarHeightKey.Value {
        get {
            hostingWindow()?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
    }
#endif
}
