//
//  UIKit2SwiftUIViewController.swift
//  SwiftUI_UIKit
//
//  Created by ChenHui on 2025/2/11.
//

import UIKit
import SwiftUI

class UIKit2SwiftUIViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let hostingController = UIHostingController(rootView: SwiftUIView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.backgroundColor = .red
        hostingController.didMove(toParent: self)
        //这里的宽高是自适应
        hostingController.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

private struct SwiftUIView: View {
    var body: some View {
        VStack {
            Text("Hello from SwiftUI! 1")
            Text("Hello from SwiftUI! 2")
            Text("Hello from SwiftUI! 3")
            Button("Tap") {
                debugPrint("click button !!!")
            }
            .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .background(Color.blue)

    }
}
