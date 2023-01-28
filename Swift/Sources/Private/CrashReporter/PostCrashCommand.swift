//
//  File.swift
//  
//
//  Created by Tigran on 29.01.23.
//

import Foundation

struct PostCrashCommand: CommonCommand {
    
    let file: URL
    
    func execute() {
        let request = NSMutableURLRequest(url: URL(string: ErrorlesCrashReporter.k_BASE_URL + "crash")!)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let data = try! Data(contentsOf: file)
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(file.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/vnd.apple.crashreport\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body as Data

        URLSession.shared.dataTask(with: request as URLRequest).resume()
        // MARK: Tigran - add saving to realm functionality.
    }
}
