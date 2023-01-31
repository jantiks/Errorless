
//
//  File.swift
//
//
//  Created by Tigran on 29.01.23.
//

#if canImport(UIKit)
import UIKit

final class AppDelegateSwizzlings {
    
    func swizzle() {
        guard let appDelegate = UIApplication.shared.delegate, let appDelegateClass = object_getClass(appDelegate) else { return }
        
        swizzleDidReceiveRemoteNotification(appDelegateClass, delegate: appDelegate)
        swizzleApplicationDidBecomeActive(appDelegateClass, delegate: appDelegate)
        swizzleApplicationWillEnterForeground(appDelegateClass, delegate: appDelegate)
        swizzleApplicationWillResignActive(appDelegateClass, delegate: appDelegate)
        swizzleApplicationDidEnterBackground(appDelegateClass, delegate: appDelegate)
        swizzleApplicationWillTerminate(appDelegateClass, delegate: appDelegate)
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
        ErrorlessTracker().track(.willEnterForeground)
    }
    
    @objc private func didBecomeActive(_ application: UIApplication) {
        ErrorlessTracker().track(.didBecomeActive)
    }
    
    @objc private func willResignActive(_ application: UIApplication) {
        ErrorlessTracker().track(.willResignActive)
    }
    
    @objc private func didEnterBackground(_ application: UIApplication) {
        ErrorlessTracker().track(.didEnterBackground)
    }
    
    @objc private func willTerminate(_ application: UIApplication) {
        ErrorlessTracker().track(.willTerminate)
    }

    private func swizzleDidReceiveRemoteNotification(_ appDelegateClass: AnyClass, delegate: UIApplicationDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: appDelegateClass, defaultSelector: #selector(delegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)), newClass: AppDelegateSwizzlings.self, with: #selector(application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
    }
    
    private func swizzleApplicationWillEnterForeground(_ appDelegateClass: AnyClass, delegate: UIApplicationDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: appDelegateClass, defaultSelector: #selector(delegate.applicationWillEnterForeground(_:)), newClass: AppDelegateSwizzlings.self, with: #selector(willEnterForeground(_:)))
    }
    
    private func swizzleApplicationDidBecomeActive(_ appDelegateClass: AnyClass, delegate: UIApplicationDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: appDelegateClass, defaultSelector: #selector(delegate.applicationDidBecomeActive(_:)), newClass: AppDelegateSwizzlings.self, with: #selector(didBecomeActive(_:)))
    }
    
    private func swizzleApplicationWillResignActive(_ appDelegateClass: AnyClass, delegate: UIApplicationDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: appDelegateClass, defaultSelector: #selector(delegate.applicationWillResignActive(_:)), newClass: AppDelegateSwizzlings.self, with: #selector(willResignActive(_:)))
    }
    
    private func swizzleApplicationDidEnterBackground(_ appDelegateClass: AnyClass, delegate: UIApplicationDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: appDelegateClass, defaultSelector: #selector(delegate.applicationDidEnterBackground(_:)), newClass: AppDelegateSwizzlings.self, with: #selector(didEnterBackground(_:)))
    }
    
    private func swizzleApplicationWillTerminate(_ appDelegateClass: AnyClass, delegate: UIApplicationDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: appDelegateClass, defaultSelector: #selector(delegate.applicationWillTerminate(_:)), newClass: AppDelegateSwizzlings.self, with: #selector(willTerminate(_:)))
    }
}
#endif
