//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by ChenHui on 2024/8/8.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .normal
        window.makeKeyAndVisible()
        return window
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //
        self.window!.rootViewController = ViewController()
        return true
    }

}

