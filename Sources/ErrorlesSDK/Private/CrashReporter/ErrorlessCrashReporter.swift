//
//  ErrorlessCrashReporter.swift
//  
//
//  Created by Tigran on 07.01.23.
//

import CrashReporter

struct ErrorlessCrashReporter {
    func initalize() {
        guard let crashReporter = PLCrashReporter.shared() else {
            return
        }
        
        if crashReporter.hasPendingCrashReport() {
            handleCrashReport(crashReporter)
        }
        
        if !crashReporter.enable() {
            print("Could not enable crash reporter")
        }
    }

    func handleCrashReport(_ crashReporter: PLCrashReporter) {
        guard let crashData = try? crashReporter.loadPendingCrashReportDataAndReturnError(), let report = try? PLCrashReport(data: crashData), !report.isKind(of: NSNull.classForCoder()) else {
            crashReporter.purgePendingCrashReport()
            return
        }

        let crash: NSString = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS)! as NSString
        // process the crash report, send it to a server, log it, etc
        print("CRASH REPORT:\n \(crash)")
        crashReporter.purgePendingCrashReport()
    }
}
