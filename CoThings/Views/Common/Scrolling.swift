//
//  Scrolling.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/10.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey, Equatable {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollOffsetModifier: ViewModifier {
    func body(content: Content) -> some View {
        let geomReader = GeometryReader { geom in
            Rectangle()
                .fill(Color.clear)
                .preference(key: ScrollOffsetPreferenceKey.self,
                            value: geom.frame(in: .global).minY)
        }
        
        return content.background(geomReader)
    }
}

extension View {
    func scrollOffset() -> some View {
        modifier(ScrollOffsetModifier())
    }
    
    func onScrollOffsetChange(perform: @escaping (CGFloat) -> Void) -> some View {
        onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: perform)
    }
}
