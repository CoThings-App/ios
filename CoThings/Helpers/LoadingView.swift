//
//  LoadingView.swift
//  CoThings
//
//  Initial Version Created by Karthick Selvaraj on 23/05/20
//  in ActivityAnimations (https://github.com/karthironald/ActivityAnimations)
//
//  Modified by Jay Zisch on 2020/06/14.
//  Modified by Nesim Tunç on 2020/06/14.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct LoadingView: View {

    var shouldAnimate = false

    @State var animating = false
    var body: some View {
        GeometryReader { geom in
            HStack {

                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .scaleEffect(self.animating ? 1.0 : 0.5)
                    .animation(Animation.easeInOut(duration: 0.5)
                        .repeatForever())

                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .scaleEffect(self.animating ? 1.0 : 0.5)
                    .animation(Animation.easeInOut(duration: 0.5)
                        .repeatForever().delay(0.3))

                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .scaleEffect(self.animating ? 1.0 : 0.5)
                    .animation(Animation.easeInOut(duration: 0.5)
                        .repeatForever().delay(0.6))
            }.onAppear {

                self.animating = self.shouldAnimate
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
