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
    
    @objc static private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
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
    
    @objc static private func willEnterForeground() {
        ErrorlessTracker().track(.willEnterForeground)
    }
    
    @objc static private func didBecomeActive() {
        ErrorlessTracker().track(.didBecomeActive)
    }
    
    @objc static private func willResignActive() {
        ErrorlessTracker().track(.willResignActive)
    }
    
    @objc static private func didEnterBackground() {
        ErrorlessTracker().track(.didEnterBackground)
    }
    
    @objc static private func willTerminate() {
        ErrorlessTracker().track(.willTerminate)
    }

    private func swizzleDidReceiveRemoteNotification() {
        swizzle(defaultSelector: #selector(application.delegate!.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)), with: #selector(AppDelegateSwizzlings.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
    }
    
    private func swizzleApplicationWillEnterForeground() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationWillEnterForeground(_:)), with: #selector(AppDelegateSwizzlings.willEnterForeground))
    }
    
    private func swizzleApplicationDidBecomeActive() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationDidBecomeActive(_:)), with: #selector(AppDelegateSwizzlings.didBecomeActive))
    }
    
    private func swizzleApplicationWillResignActive() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationWillResignActive(_:)), with: #selector(AppDelegateSwizzlings.willResignActive))
    }
    
    private func swizzleApplicationDidEnterBackground() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationDidEnterBackground(_:)), with: #selector(AppDelegateSwizzlings.didEnterBackground))
    }
    
    private func swizzleApplicationWillTerminate() {
        swizzle(defaultSelector: #selector(application.delegate!.applicationWillTerminate(_:)), with: #selector(AppDelegateSwizzlings.willTerminate))
    }
    
    private func swizzle(defaultSelector: Selector, with newSelector: Selector) {
        let appDelegate = application.delegate!
        let appDelegateClass: AnyClass? = object_getClass(appDelegate)

        let defaultInstace = class_getInstanceMethod(appDelegateClass.self, defaultSelector)
        let newInstance = class_getInstanceMethod(appDelegateClass.self, newSelector)

        if let instance1 = defaultInstace, let instance2 = newInstance {
            debugPrint("ASD swizzling worked appdelegate")
            method_exchangeImplementations(instance1, instance2)
        }
    }
}
#endif
