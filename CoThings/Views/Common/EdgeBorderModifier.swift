//
//  DirectionalBorderModifier.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/09.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct EdgeBorder<S>: ViewModifier where S: ShapeStyle {
    let content: S
    let width: Float
    let edges: Edge.Set
    
    init(_ content: S, width: Float = 1, edges: Edge.Set = .all) {
        self.content = content
        self.width = width
        self.edges = edges
    }
    
    func body(content: Content) -> some View {
        let rect = Rectangle().fill(self.content)
        let horizontalLine = rect.frame(maxWidth: .infinity).frame(height: 1)
        let verticalLine = rect.frame(maxHeight: .infinity).frame(width: 1)
        
        return content
            .overlay(edgeOrEmptyView(.top, view: horizontalLine), alignment: .topLeading)
            .overlay(edgeOrEmptyView(.bottom, view: horizontalLine), alignment: .bottomLeading)
            .overlay(edgeOrEmptyView(.leading, view: verticalLine), alignment: .topLeading)
            .overlay(edgeOrEmptyView(.trailing, view: verticalLine), alignment: .topTrailing)
    }
    
    func edgeOrEmptyView<V: View>(_ edge: Edge.Set, view: V) -> some View {
        Group {
            if edges.contains(edge) {
                view
            } else {
                EmptyView()
            }
        }
    }
}

extension View {
    func edgeBorder<S: ShapeStyle>(_ content: S, width: Float = 1, edges: Edge.Set = .all) -> some View {
        self.modifier(EdgeBorder(content, width: width, edges: edges))
    }
}

struct DirectionalBorder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Rectangle()
                .fill(Color(hex: "eeeeee"))
                .frame(width: 300, height: 300)
                .edgeBorder(Color(hex: "cccccc"))
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Rectangle")
            
            Button("Hello") {
                
            }
            .edgeBorder(Color(hex: "cccccc"))
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Button")
        }
    }
}
