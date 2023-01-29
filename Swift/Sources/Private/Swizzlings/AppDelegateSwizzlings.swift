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
        swizzle(defaultSelector: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)), with: #selector(AppDelegateSwizzlings.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
    }
    
    private func swizzleApplicationWillEnterForeground() {
        swizzle(defaultSelector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), with: #selector(AppDelegateSwizzlings.willEnterForeground))
    }
    
    private func swizzleApplicationDidBecomeActive() {
        swizzle(defaultSelector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)), with: #selector(AppDelegateSwizzlings.didBecomeActive))
    }
    
    private func swizzleApplicationWillResignActive() {
        swizzle(defaultSelector: #selector(UIApplicationDelegate.applicationWillResignActive(_:)), with: #selector(AppDelegateSwizzlings.willResignActive))
    }
    
    private func swizzleApplicationDidEnterBackground() {
        swizzle(defaultSelector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), with: #selector(AppDelegateSwizzlings.didEnterBackground))
    }
    
    private func swizzleApplicationWillTerminate() {
        swizzle(defaultSelector: #selector(UIApplicationDelegate.applicationWillTerminate(_:)), with: #selector(AppDelegateSwizzlings.willTerminate))
    }
    
    private func swizzle(defaultSelector: Selector, with newSelector: Selector) {
        let appDelegate = UIApplication.shared.delegate
        let appDelegateClass: AnyClass? = object_getClass(appDelegate)

        guard let newSelectorMethod = class_getInstanceMethod(AppDelegateSwizzlings.self, newSelector) else {
            return
        }

        if let originalMethod = class_getInstanceMethod(appDelegateClass, defaultSelector)  {
            // exchange implementation
            method_exchangeImplementations(originalMethod, newSelectorMethod)
        } else {
            // add implementation
            class_addMethod(appDelegateClass, newSelector, method_getImplementation(newSelectorMethod), method_getTypeEncoding(newSelectorMethod))
        }
    }
}
#endif
