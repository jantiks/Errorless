//
//  File.swift
//  
//
//  Created by Tigran on 31.01.23.
//

import UIKit

@available(iOS 13.0, *)
final class SceneDelegateSwizzlings {
    
    static let shared = SceneDelegateSwizzlings()
    
    func swizzle() {
        print("asd swizzle")
        NotificationCenter.default.addObserver(self, selector: #selector(testObserver), name: NSNotification.Name(rawValue: "NotificationIdentifier"), object: nil)
        if UIApplication.shared.connectedScenes.isEmpty {
            NotificationCenter.default.addObserver(self, selector: #selector(sceneWillConnect(_:)), name: UIScene.willConnectNotification, object: nil)
        } else {
            sceneWillConnect(Notification(name: UIScene.willConnectNotification))
        }
    }
    
    @objc private func testObserver() {
        print("asd called test post notification")
    }
    
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
    
    @objc private func didBecomeActive(_ scene: UIScene) {
        ErrorlessTracker().track(.didBecomeActive)
    }

    @objc private func willResignActive(_ scene: UIScene) {
        ErrorlessTracker().track(.willResignActive)
    }

    @objc private func willEnterForeground(_ scene: UIScene) {
        ErrorlessTracker().track(.willEnterForeground)
    }
    
    @objc private func didEnterBackground(_ scene: UIScene) {
        ErrorlessTracker().track(.didEnterBackground)
    }
        
    @objc private func sceneDidDisconnect(_ scene: UIScene) {
        ErrorlessTracker().track(.sceneDidDisconnect)
    }
    
    private func swizzleSceneWillEnterForeground(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneWillEnterForeground(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(willEnterForeground(_:)))
    }
    
    private func swizzleSceneDidBecomeActive(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneDidBecomeActive(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(didBecomeActive(_:)))
    }
    
    private func swizzleSceneWillResignActive(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneWillResignActive(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(willResignActive(_:)))
    }
    
    private func swizzleSceneDidEnterBackground(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneDidEnterBackground(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(didEnterBackground(_:)))
    }
    
    private func swizzleSceneWillTerminate(_ sceneDelegateClass: AnyClass, delegate: UISceneDelegate) {
        SceneSwizzlingHelper.swizzle(defaultClass: sceneDelegateClass, defaultSelector: #selector(delegate.sceneDidDisconnect(_:)), newClass: SceneDelegateSwizzlings.self, with: #selector(sceneDidDisconnect(_:)))
    }
}
