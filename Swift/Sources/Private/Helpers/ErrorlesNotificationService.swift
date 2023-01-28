//
//  ErrorlessNotificationService.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import UIKit

class ErrorlesNotificationService {
    func initalize() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func rotated() {
        if UIDevice.current.orientation.isLandscape {
            ErrorlessTracker().track(.changeToLandscape)
        }

        if UIDevice.current.orientation.isPortrait {
            ErrorlessTracker().track(.changeToPortrait)
        }
    }
}
