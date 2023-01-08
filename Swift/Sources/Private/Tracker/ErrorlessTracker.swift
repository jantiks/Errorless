//
//  ErrorlessTracker.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import Foundation

struct ErrorlessTracker {
    func trackViewDidLoad(message: String) {
        print("SWIZZLING: ViewDidLoad: \(message)")
    }
    
    func trackViewWillAppear(message: String) {
        print("SWIZZLING: viewWillAppear: \(message)")
    }
    
    func trackViewWillDisappear(message: String) {
        print("SWIZZLING: viewWillDisappear: \(message)")
    }
    
    func trackPortrait(message: String) {
        print("trackPortrait: \(message)")
    }
    
    func trackLandscape(message: String) {
        print("trackLandscape: \(message)")
    }
}
