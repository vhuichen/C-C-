//
//  ObservedObject.swift
//  SwiftUIDemo
//
//  Created by vchan on 2024/8/4.
//

import SwiftUI

class ObservedObjectPerson: ObservableObject {
    @Published var count = 0
    deinit{
        print("ObservableObject 销毁了")
    }
}
struct ObservedObjectExample: View {
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
struct ObservedObjectMapView: View {
    // ObservedObject 页面刷新时，对象会销毁，会调用 deinit
    // 需要真机演示
     @ObservedObject var p = ObservedObjectPerson()
    var body: some View {
        VStack{
            Text("\(p.count)")
            Button("点击+1") {
                p.count += 1
            }
 
        }
    }
}


struct ObservedObject_Previews: PreviewProvider {
    static var previews: some View {
        ObservedObjectExample()
    }
}
