//
//  File.swift
//  
//
//  Created by Tigran on 31.01.23.
//

import Foundation


struct SceneSwizzlingHelper {
    static func swizzle(defaultClass: AnyClass, defaultSelector: Selector, newClass: AnyClass, with newSelector: Selector) {
        let defaultInstace = class_getInstanceMethod(defaultClass.self, defaultSelector)

        guard let newInstance = class_getInstanceMethod(newClass.self, newSelector) else {
            return
        }
        
        if let defaultInstace = defaultInstace {
            debugPrint("ASD swizzling worked appdelegate")
            method_exchangeImplementations(defaultInstace, newInstance)
        } else {
            // add implementation
            debugPrint("ASD Add Implementation worked appdelegate")
            class_addMethod(defaultClass, newSelector, method_getImplementation(newInstance), method_getTypeEncoding(newInstance))
        }
    }
}
