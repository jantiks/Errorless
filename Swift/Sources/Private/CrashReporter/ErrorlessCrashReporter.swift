//
//  ErrorlessCrashReporter.swift
//
//
//  Created by Tigran on 07.01.23.
//

import CrashReporter
import UIKit

struct ErrorlessCrashReporter {
    
    static var k_BASE_URL = "http://127.0.0.1:8000/"
    
    func initalize() {
        guard !amIBeingDebugged() else {
            return
        }
        
        DispatchQueue.main.async {
            let config = PLCrashReporterConfig(signalHandlerType: .mach, symbolicationStrategy: [])
            guard let crashReporter = PLCrashReporter(configuration: config) else {
                print("Could not create an instance of PLCrashReporter")
                return
            }

            // Enable the Crash Reporter.
            do {
                try crashReporter.enableAndReturnError()
            } catch let error {
                print("Warning: Could not enable crash reporter: \(error)")
            }

            // Try loading the crash report.
            if crashReporter.hasPendingCrashReport() {
                do {
                    let data = try crashReporter.loadPendingCrashReportDataAndReturnError()
                    
                    // Retrieving crash reporter data.
                    let report = try PLCrashReport(data: data)
                    
                    let crash = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS)

                    let outputPath = getDocumentsDirectory().appendingPathComponent("app.crash")
                    do {
                        try crash?.write(to: outputPath, atomically: true, encoding: .utf8)
                        dump(outputPath.absoluteString)
                        dump("data \(try! Data(contentsOf: outputPath))")
                        postCrash(outputPath)
                        print("Saved crash report to: \(outputPath)")
                    } catch {
                        print("Failed to write crash report")
                        dump("Coudnl't write the file at directory \(outputPath.relativeString)")
                    }
                } catch let error {
                    dump("CrashReporter failed to load and parse with error: \(error)")
                }
            }

            // Purge the report.
            crashReporter.purgePendingCrashReport()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    private func postCrash(_ file: URL) {
        let request = NSMutableURLRequest(url: URL(string: ErrorlessCrashReporter.k_BASE_URL + "crash")!)
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

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let error = error {
                self.dump(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    private func dump(_ info: String) {
        var req = URLRequest(url: URL(string: ErrorlessCrashReporter.k_BASE_URL + "dump")!)
        
        req.httpMethod = "POST"
        req.httpBody = try! JSONSerialization.data(withJSONObject: ["body": "\(info)"], options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: req) { data, response, error in
            print((response as? HTTPURLResponse)?.statusCode)
        }.resume()
    }
}
