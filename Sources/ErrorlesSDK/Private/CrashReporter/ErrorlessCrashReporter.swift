//
//  ErrorlessCrashReporter.swift
//  
//
//  Created by Tigran on 07.01.23.
//

import CrashReporter

struct ErrorlessCrashReporter {
    func initalize() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
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
                        print(text)
                    } else {
                        print("CrashReporter: can't convert report to text")
                    }
                } catch let error {
                    print("CrashReporter failed to load and parse with error: \(error)")
                }
            }
            
            // Purge the report.
            crashReporter.purgePendingCrashReport()
        })
    }
}
