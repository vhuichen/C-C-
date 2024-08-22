//
//  ViewController.swift
//  SwiftDemo
//
//  Created by vchan on 2024/7/27.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showSwiftUIView()
        
        
        
        
    }

    // 在 UIKit 视图控制器中调用
    func showSwiftUIView() {
        let swiftUIView = CircularSliderView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.frame = view.bounds
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
