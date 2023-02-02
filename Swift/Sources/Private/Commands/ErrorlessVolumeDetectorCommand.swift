//
//  File.swift
//  
//
//  Created by Tigran on 01.02.23.
//

import Foundation

struct ErrorlessVolumeDetectorCommand: CommonCommand {
    func execute() {
        let fileURL = URL(fileURLWithPath:"/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let capacity = values.volumeAvailableCapacityForImportantUsage {
                ErrorlessTracker().track(.storage, body: ["volume": "\(capacity)"])
            } else {
                print("Capacity is unavailable")
            }
        } catch {
            print("Error retrieving capacity: \(error.localizedDescription)")
        }
    }
}
