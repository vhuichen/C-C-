//
//  AppDelegate.swift
//  SwiftUI_UIKit
//
//  Created by ChenHui on 2025/2/11.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.windowLevel = .normal
        window.makeKeyAndVisible()
        self.window = window
        
        let nav = UINavigationController(rootViewController: ViewController())
        self.window?.rootViewController = nav
        
        return true
    }

}

