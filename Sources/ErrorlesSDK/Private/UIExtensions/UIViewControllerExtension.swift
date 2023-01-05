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
        debugPrint("Swizzleeee. Call NEW view did load ")
    }
    
    static func startSwizzlingViewDidLoad() {
       let defaultSelector = #selector(viewDidLoad)
       let newSelector = #selector(viewDidLoadSwizzlingMethod)

       let defaultInstace = class_getInstanceMethod(UIViewController.self, defaultSelector)
       let newInstance = class_getInstanceMethod(UIViewController.self, newSelector)
       
       if let instance1 = defaultInstace, let instance2 = newInstance {
           debugPrint("Swizzlle for all view controller success")
           method_exchangeImplementations(instance1, instance2)
       }
   }
}
#endif



