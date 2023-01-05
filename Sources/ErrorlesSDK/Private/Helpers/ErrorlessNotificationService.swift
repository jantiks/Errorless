//
//  ErrorlessNotificationService.swift
//  
//
//  Created by Tigran on 05.01.23.
//

import Foundation
import UIKit

class ErrorlessNotificationService {
    func initalize() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func rotated() {
        if UIDevice.current.orientation.isLandscape {
            ErrorlessTracker().trackLandscape(message: "asd")
        }

        if UIDevice.current.orientation.isPortrait {
            ErrorlessTracker().trackPortrait(message: "asd")
        }
    }
}
