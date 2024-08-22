//
//  StackViewExample.swift
//  SwiftUIDemo
//
//  Created by vchan on 2024/7/27.
//

import SwiftUI

struct StackViewExample: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            HStack {
                Spacer()
                Button(action: {
                    debugPrint("tap 001")
                }, label: {
                    Text("My name is hahaha")
                })
                Spacer()
                Button("Animate Me!") {
                    debugPrint("tap 002")
                }
                Spacer()
            }
        }
        .padding()
    }
}

struct StackViewExample_Previews: PreviewProvider {
    static var previews: some View {
        StackViewExample()
    }
}
