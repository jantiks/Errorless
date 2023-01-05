//
//  ErrorlessTracker.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import Foundation

struct ErrorlessTracker {
    func trackViewDidLoad() {
        print("SWIZZLING: ViewDidLoad")
    }
    
    func trackViewWillAppear() {
        print("SWIZZLING: viewWillAppear")
    }
    
    func trackViewWillDisappear() {
        print("SWIZZLING: viewWillDisappear")
    }
    
    func trackPortrait() {
        print("trackPortrait")
    }
    
    func trackLandscape() {
        print("trackLandscape")
    }
}
