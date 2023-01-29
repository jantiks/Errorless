//
//  File.swift
//  
//
//  Created by Tigran on 29.01.23.
//

import Foundation

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxx"
        return formatter.string(from: self)
    }
}
