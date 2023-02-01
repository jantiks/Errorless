//
//  File.swift
//  
//
//  Created by Tigran on 01.02.23.
//

import CallKit
import UIKit

class SharedObserver: NSObject {
    
    static let shared = SharedObserver()
    
    func initalize() {
        CXCallObserver().setDelegate(self, queue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreeshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        swizzle()
    }
    
    func swizzle() {
        if #available(iOS 13.0, *) {
            if UIApplication.shared.connectedScenes.isEmpty {
                NotificationCenter.default.addObserver(self, selector: #selector(sceneWillConnect(_:)), name: UIScene.willConnectNotification, object: nil)
            } else {
                sceneWillConnect(Notification(name: UIScene.willConnectNotification))
            }
        }
    }
    
    @objc private func rotated() {
        if UIDevice.current.orientation.isLandscape {
            ErrorlessTracker().track(.changeToLandscape)
        }

        if UIDevice.current.orientation.isPortrait {
            ErrorlessTracker().track(.changeToPortrait)
        }
    }

    @objc private func didTakeScreeshot() {
        ErrorlessTracker().track(.didTakeScreeshot)
    }

    @available(iOS 13.0, *)
    @objc private func sceneWillConnect(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)

        UIApplication.shared.connectedScenes.forEach({ [weak self] in
            guard let self = self else { return }
            if let sceneDeleage = $0.delegate, let sceneDelegateClass = object_getClass(sceneDeleage) {
                self.swizzleSceneDidBecomeActive(sceneDelegateClass, delegate: sceneDeleage)
                self.swizzleSceneWillEnterForeground(sceneDelegateClass, delegate: sceneDeleage)
                self.swizzleSceneWillResignActive(sceneDelegateClass, delegate: sceneDeleage)
                self.swizzleSceneDidEnterBackground(sceneDelegateClass, delegate: sceneDeleage)
                self.swizzleSceneWillTerminate(sceneDelegateClass, delegate: sceneDeleage)
            }
        })
    }
    
    @available(iOS 13.0, *)
    @objc private func didBecomeActive(_ scene: UIScene) {
        ErrorlessTracker().track(.didBecomeActive)
    }

    @available(iOS 13.0, *)
    @objc private func willResignActive(_ scene: UIScene) {
        ErrorlessTracker().track(.willResignActive)
    }

    @available(iOS 13.0, *)
    @objc private func willEnterForeground(_ scene: UIScene) {
        ErrorlessTracker().track(.willEnterForeground)
    }
    
    @available(iOS 13.0, *)
    @objc private func didEnterBackground(_ scene: UIScene) {
        ErrorlessTracker().track(.didEnterBackground)
    }
    
    @available(iOS 13.0, *)
    @objc private func sceneDidDisconnect(_ scene: UIScene) {
        ErrorlessTracker().track(.sceneDidDisconnect)
    }
    
    @available(iOS 13.0, *)
    private func swizzleSceneWillEnterForeground(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneWillEnterForeground(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(willEnterForeground(_:)))
    }
    
    @available(iOS 13.0, *)
    private func swizzleSceneDidBecomeActive(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneDidBecomeActive(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(didBecomeActive(_:)))
    }
    
    @available(iOS 13.0, *)
    private func swizzleSceneWillResignActive(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneWillResignActive(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(willResignActive(_:)))
    }
    
    @available(iOS 13.0, *)
    private func swizzleSceneDidEnterBackground(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneDidEnterBackground(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(didEnterBackground(_:)))
    }
    
    @available(iOS 13.0, *)
    private func swizzleSceneWillTerminate(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneDidDisconnect(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(sceneDidDisconnect(_:)))
    }
}

extension SharedObserver:  CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            ErrorlessTracker().track(.callDisconnected)
        }
        
        if call.isOutgoing == true && call.hasConnected == false {
            ErrorlessTracker().track(.callDialing)
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            ErrorlessTracker().track(.incomingCall)
        }

        if call.hasConnected == true && call.hasEnded == false {
            ErrorlessTracker().track(.callConnected)
        }
    }
}
