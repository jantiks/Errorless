//
//  File.swift
//  
//
//  Created by Tigran on 29.01.23.
//

import Foundation

#if canImport(UIKit)
import UIKit

class AppDelegateSwizzlings {
    
    private let application: UIApplication
    
    init(_ application: UIApplication) {
        self.application = application
    }
    
    func swizzle() {
        swizzleDidReceiveRemoteNotification()
        swizzleApplicationDidBecomeActive()
        swizzleApplicationWillEnterForeground()
        swizzleApplicationWillResignActive()
    }
    
    @objc private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        struct Root: Codable {
            let title: String?
            let message: String?
        }
        
        if let str = userInfo["data"] as? String {
            let res = try? JSONDecoder().decode(Root.self, from: str.data(using: .utf8)!)
            ErrorlessTracker().trackRecieveNotification(body: RecieveNotificationRequestBody(title: res?.title, message: res?.message))
        } else {
            ErrorlessTracker().trackRecieveNotification(body: RecieveNotificationRequestBody(title: nil, message: nil))
        }
    }
    
    @objc private func willEnterForeground(_ application: UIApplication) {
        willEnterForeground(application)
        ErrorlessTracker().track(.willEnterForeground)
    }
    
    @objc private func didBecomeActive(_ application: UIApplication) {
        didBecomeActive(application)
        ErrorlessTracker().track(.didBecomeActive)
    }
    
    @objc private func willResignActive(_ application: UIApplication) {
        willResignActive(application)
        ErrorlessTracker().track(.willResignActive)
    }
    
    @objc private func didEnterBackground(_ application: UIApplication) {
        didEnterBackground(application)
        ErrorlessTracker().track(.didEnterBackground)
    }
    
    @objc private func willTerminate(_ application: UIApplication) {
        willTerminate(application)
        ErrorlessTracker().track(.willTerminate)
    }

    private func swizzleDidReceiveRemoteNotification() {
        swizzle(defaultSelector: #selector(application.delegate!.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)), with: #selector(application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
    }
    
    private func swizzleApplicationWillEnterForeground() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationWillEnterForeground(_:)), with: #selector(willEnterForeground(_:)))
    }
    
    private func swizzleApplicationDidBecomeActive() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationDidBecomeActive(_:)), with: #selector(didBecomeActive(_:)))
    }
    
    private func swizzleApplicationWillResignActive() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationWillResignActive(_:)), with: #selector(willResignActive(_:)))
    }
    
    private func swizzleApplicationDidEnterBackground() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationDidEnterBackground(_:)), with: #selector(didEnterBackground(_:)))
    }
    
    private func swizzleApplicationWillTerminate() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationWillTerminate(_:)), with: #selector(willTerminate(_:)))
    }
    
    private func swizzle(defaultSelector: Selector, with newSelector: Selector) {
        let appDelegate = application.delegate!
        let appDelegateClass: AnyClass? = object_getClass(appDelegate)

        let defaultInstace = class_getInstanceMethod(appDelegateClass.self, defaultSelector)
        let newInstance = class_getInstanceMethod(AppDelegateSwizzlings.self, newSelector)

        if let instance1 = defaultInstace, let instance2 = newInstance {
            debugPrint("ASD swizzling worked appdelegate")
            method_exchangeImplementations(instance1, instance2)
        }
    }
}
#endif
