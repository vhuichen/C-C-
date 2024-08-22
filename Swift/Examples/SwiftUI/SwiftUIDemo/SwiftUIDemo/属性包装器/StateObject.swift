//
//  StateObject.swift
//  SwiftUIDemo
//
//  Created by vchan on 2024/8/4.
//

import SwiftUI

class Person: ObservableObject {
    @Published var count = 0
    deinit{
        print("ObservableObject 销毁了")
    }
}
struct StateObjectExample: View {
    @State var count = 0
    var body: some View {
        VStack{
            MapView()
            Text("CounterView:\(count)")
            Button("刷新") {
                count += 1
            }
        }
    }
}
struct MapView: View {
    // StateObject页面刷新时，对象不会销毁，不会调用 deinit
    // 需要真机演示
    @StateObject var p = Person()
    var body: some View {
        VStack{
            Text("\(p.count)")
            Button("点击+1") {
                p.count += 1
            }
        }
    }
}

struct StateObject_Previews: PreviewProvider {
    static var previews: some View {
        StateObjectExample()
    }
}
