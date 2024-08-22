//
//  TabViewExample.swift
//  SwiftUIDemo
//
//  Created by vchan on 2024/8/3.
//

import SwiftUI

struct TabViewInSwiftUI: View {
    var body: some View {
        TabView {
            ForEach(0..<5) { index in
                ZStack {
                    Color.red
                    Text("Current Page -> \(index)").foregroundColor(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            }
            .padding(.all, 10)
        }
        .frame(width: UIScreen.main.bounds.width, height: 200)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
    }
}

struct TabViewExample: View {
    var body: some View {
        VStack {
            TabViewInSwiftUI()
            Spacer()
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        TabViewExample()
    }
}
