//
//  ListViewExample.swift
//  SwiftUIDemo
//
//  Created by vchan on 2024/7/27.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let details: String
    var isClick: Bool
    
    init(name: String, details: String, isClick: Bool = false) {
        self.name = name
        self.details = details
        self.isClick = isClick
    }
}

struct ListViewExample: View {
    @State private var items = [
         Item(name: "Apple", details: "Fruit"),
         Item(name: "Banana", details: "Fruit"),
         Item(name: "Carrot", details: "Vegetable")
    ]
    
    var body: some View {
        List(items) { item in
            ZStack {
                Button(action: {
                    toggleItem(item)
                    print("vhuichen \(item.isClick)")
                })
                {
                    EmptyView()
                }
                .background(Color.clear)
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name).font(.headline)
                        if item.isClick {
                            Text(item.details).font(.subheadline)
                        }
                        Text(item.isClick ? "按钮已被点击" : "点击按钮")
                    }
                    Spacer() // 这将填充剩余的空间
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func toggleItem(_ itemNew: Item) {
        items = items.map({ item in
            if itemNew.id == item.id {
                return Item(name: item.name, details: item.details, isClick: !item.isClick)
            }
            return item
        })
    }
    
}

struct ListViewExample_Previews: PreviewProvider {
    static var previews: some View {
        ListViewExample()
    }
}
