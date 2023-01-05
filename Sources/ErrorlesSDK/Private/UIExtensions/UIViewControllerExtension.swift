//
//  UIViewControllerExtension.swift
//  
//
//  Created by Tigran on 05.01.23.
//

#if canImport(UIKit)
import UIKit

extension UIViewController {
    
    @objc func viewDidLoadSwizzlingMethod() {
        viewDidLoadSwizzlingMethod()
        ErrorlessTracker().trackViewDidLoad()
    }
    
    static func startSwizzlingViewDidLoad() {
        let defaultSelector = #selector(viewDidLoad)
        let newSelector = #selector(viewDidLoadSwizzlingMethod)
        
        let defaultInstace = class_getInstanceMethod(UIViewController.self, defaultSelector)
        let newInstance = class_getInstanceMethod(UIViewController.self, newSelector)
        
        if let instance1 = defaultInstace, let instance2 = newInstance {
            method_exchangeImplementations(instance1, instance2)
        }
    }
    
    @objc func viewWillAppearSwizzlingMethod() {
        viewWillAppearSwizzlingMethod()
        ErrorlessTracker().trackViewWillAppear()
    }
    
    static func startSwizzlingViewWillAppear() {
        let defaultSelector = #selector(viewWillAppear)
        let newSelector = #selector(viewWillAppearSwizzlingMethod)
        
        let defaultInstace = class_getInstanceMethod(UIViewController.self, defaultSelector)
        let newInstance = class_getInstanceMethod(UIViewController.self, newSelector)
        
        if let instance1 = defaultInstace, let instance2 = newInstance {
            method_exchangeImplementations(instance1, instance2)
        }
    }
    
    @objc func viewWillDisappearSwizzlingMethod() {
        viewWillDisappearSwizzlingMethod()
        ErrorlessTracker().trackViewWillDisappear()
    }
    
    static func startSwizzlingViewWillDisappear() {
        let defaultSelector = #selector(viewWillDisappear)
        let newSelector = #selector(viewDidLoadSwizzlingMethod)
        
        let defaultInstace = class_getInstanceMethod(UIViewController.self, defaultSelector)
        let newInstance = class_getInstanceMethod(UIViewController.self, newSelector)
        
        if let instance1 = defaultInstace, let instance2 = newInstance {
            method_exchangeImplementations(instance1, instance2)
        }
    }
}
#endif



