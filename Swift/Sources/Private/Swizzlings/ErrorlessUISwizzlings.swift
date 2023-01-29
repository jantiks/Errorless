//
//  ErrorlessUISwizzlings.swift
//  
//
//  Created by Tigran on 05.01.23.
//

#if canImport(UIKit)
import UIKit

struct ErrorlessUISwizzlings {
    func swizzle() {
        UIViewController.startSwizzlingViewDidLoad()
        UIViewController.startSwizzlingViewWillAppear()
        UIViewController.startSwizzlingViewWillDisappear()
        UIViewController.startSwizzlingViewDidLayoutSubviews()
    }
}
#endif

