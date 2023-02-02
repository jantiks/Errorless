//
//  File.swift
//  
//
//  Created by Tigran on 02.02.23.
//

import UIKit

struct JailbreakManager {
    
    //suspicious apps path to check
    private let suspiciousAppsPathToCheck = [
        "/Applications/Cydia.app",
        "/Applications/blackra1n.app",
        "/Applications/FakeCarrier.app",
        "/Applications/Icy.app",
        "/Applications/IntelliScreen.app",
        "/Applications/MxTube.app",
        "/Applications/RockApp.app",
        "/Applications/SBSettings.app",
         "/Applications/WinterBoard.app"
    ]
    
    //suspicious system paths to check
    private let suspiciousSystemPathsToCheck = [
        "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        "/private/var/lib/apt",
        "/private/var/lib/apt/",
        "/private/var/lib/cydia",
        "/private/var/mobile/Library/SBSettings/Themes",
        "/private/var/stash",
        "/private/var/tmp/cydia.log",
        "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        "/usr/bin/sshd",
        "/usr/libexec/sftp-server",
        "/usr/sbin/sshd",
        "/etc/apt",
        "/bin/bash",
        "/Library/MobileSubstrate/MobileSubstrate.dylib"
    ]
    
    func isJailBroken() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            if #available(iOS 14.0, *) {
                if ProcessInfo.processInfo.isiOSAppOnMac { return false }
            }
            if hasCydiaInstalled() { return true }
            if isContainsSuspiciousApps() { return true }
            if isSuspiciousSystemPathsExists() { return true }
            
            return canEditSystemFiles()
        #endif
    }
    
    private func hasCydiaInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    
    private func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    private func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    private func canEditSystemFiles() -> Bool {
        let jailBreakText = "Errorless Insider"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
