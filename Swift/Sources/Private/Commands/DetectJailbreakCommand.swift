//
//  File.swift
//  
//
//  Created by Tigran on 02.02.23.
//

import Foundation

struct DetectJailBreakCommand: CommonCommand {
    func execute() {
        ErrorlessTracker().track(JailbreakManager().isJailBroken() ? .isJailBroken : .notJailBroken)
    }
}
