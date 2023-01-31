//
//  ErrorlessNotificationService.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import UIKit

final class ErrorlesNotificationService {
    func initalize() {
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorlesNotificationService.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc static private func rotated() {
        if UIDevice.current.orientation.isLandscape {
            ErrorlessTracker().track(.changeToLandscape)
        }

        if UIDevice.current.orientation.isPortrait {
            ErrorlessTracker().track(.changeToPortrait)
        }
    }
}
