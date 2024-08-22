//
//  MySwiftUIView.swift
//  SwiftDemo
//
//  Created by vchan on 2024/7/27.
//

import SwiftUI

struct CircularSliderView: View {
    let progress = 0.53
    let ringDiameter = 300.0
    private var rotationAngle: Angle {
        return Angle(degrees: 360.0 * progress)
    }

    var body: some View {
        VStack {
            ZStack {
                Circle().stroke(Color(hue: 0.0, saturation: 0.0, brightness: 0.9),
                                lineWidth: 20.0)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color(hue: 0.0, saturation: 0.5, brightness: 0.9),
                            style: StrokeStyle(lineWidth: 20.0, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                Circle()
                    .fill(Color.white)
                    .frame(width: 21, height: 21)
                    .offset(y: -ringDiameter / 2.0)
                    .rotationEffect(rotationAngle)
            }
            .frame(width: ringDiameter, height: ringDiameter)

            Spacer()
        }
        .padding(80)
        .background(.gray)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CircularSliderView()
    }
}
