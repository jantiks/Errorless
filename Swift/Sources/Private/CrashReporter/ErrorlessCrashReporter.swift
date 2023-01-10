//
//  ErrorlessCrashReporter.swift
//
//
//  Created by Tigran on 07.01.23.
//

import CrashReporter
import UIKit

struct ErrorlessCrashReporter {
    func initalize() {
        guard !amIBeingDebugged() else { return }
        
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
                    // We could send the report from here, but we'll just print out some debugging info instead.
                    if let text = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS) {
//                        let vc = UIAlertController(title: "Crash", message: text, preferredStyle: .alert)
//                        vc.addAction(UIAlertAction(title: "OK", style: .default))
//                        UIApplication.shared.windows[0].rootViewController?.present(vc, animated: true)
                        postCrash(text)
                    } else {
                        print("CrashReporter: can't convert report to text")
                    }
                } catch let error {
                    print("CrashReporter failed to load and parse with error: \(error)")
                }
            }

            // Purge the report.
            crashReporter.purgePendingCrashReport()
        }
    }
    
    private func postCrash(_ crashStr: String) {
        var req = URLRequest(url: URL(string: "http://127.0.0.1:8080/crash")!)
        req.httpBody = crashStr.data(using: .utf8)!
        req.httpMethod = "POST"
        URLSession.shared.dataTask(with: req) { data, response, error in
            print((response as? HTTPURLResponse)?.statusCode)
        }.resume()
    }
    
    private func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}
