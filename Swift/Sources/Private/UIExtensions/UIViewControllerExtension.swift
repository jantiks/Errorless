//
//  UIViewControllerExtension.swift
//  
//
//  Created by Tigran on 05.01.23.
//

#if canImport(UIKit)
import UIKit

extension UIViewController {
    
    static func startSwizzlingViewDidLoad() {
        swizzle(defaultSelector: #selector(viewDidLoad), with: #selector(viewDidLoadSwizzlingMethod))
    }
    
    static func startSwizzlingViewWillDisappear() {
        swizzle(defaultSelector: #selector(viewWillDisappear), with: #selector(viewWillDisappearSwizzlingMethod))
    }
    
    static func startSwizzlingViewWillAppear() {
        swizzle(defaultSelector: #selector(viewWillAppear), with: #selector(viewWillAppearSwizzlingMethod))
    }
    
    @objc func viewDidLoadSwizzlingMethod() {
        viewDidLoadSwizzlingMethod()
        ErrorlessTracker().track(.viewDidLoad)
    }
    
    @objc func viewWillAppearSwizzlingMethod() {
        viewWillAppearSwizzlingMethod()
        ErrorlessTracker().track(.viewWillAppear)
    }
    
    @objc func viewWillDisappearSwizzlingMethod() {
        viewWillDisappearSwizzlingMethod()
        ErrorlessTracker().track(.viewWillDisappear)
    }
    
    static func swizzle(defaultSelector: Selector, with newSelector: Selector) {
        let defaultInstace = class_getInstanceMethod(UIViewController.self, defaultSelector)
        let newInstance = class_getInstanceMethod(UIViewController.self, newSelector)
        
        if let instance1 = defaultInstace, let instance2 = newInstance {
            method_exchangeImplementations(instance1, instance2)
        }
    }
}
#endif



