//
//  ErrorlessCrashReporter.swift
//
//
//  Created by Tigran on 07.01.23.
//

import CrashReporter
import UIKit

struct ErrorlessCrashReporter {
    
    private let k_BASE_URL = "http://127.0.0.1:8000/"
    
    func initalize() {
        guard !amIBeingDebugged() else {
            showMessage("I am not being debugged")
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
        let request = NSMutableURLRequest(url: URL(string: k_BASE_URL + "crash")!)
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
    
    private func showMessage(_ message: String) {
        let ac = UIAlertController(title: "asa", message: "asd", preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?.first?.text = message
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        UIApplication.shared.windows.first?.rootViewController?.present(ac, animated: true)
    }
    
    private func dump(_ info: String) {
        var req = URLRequest(url: URL(string: k_BASE_URL + "dump")!)
        
        req.httpMethod = "POST"
        req.httpBody = try! JSONSerialization.data(withJSONObject: ["body": "\(info)"], options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: req) { data, response, error in
            print((response as? HTTPURLResponse)?.statusCode)
        }.resume()
    }
}

struct RequestBody: Codable {
    let crashRepoort: String
}


import Foundation

public extension URL {

  /// Creates a zip archive of the file or folder represented by this URL and returns a references to the zipped file
  ///
  /// - parameter dest: the destination URL; if nil, the destination will be this URL with ".zip" appended
  public func zip(toFileAt dest: URL? = nil) throws -> URL
  {
    let destURL = dest ?? self.appendingPathExtension("zip")

    let fm = FileManager.default
    var isDir: ObjCBool = false

    let srcDir: URL
    let srcDirIsTemporary: Bool
    if self.isFileURL && fm.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue == true {
      // this URL is a directory: just zip it in-place
      srcDir = self
      srcDirIsTemporary = false
    }
    else {
      // otherwise we need to copy the simple file to a temporary directory in order for
      // NSFileCoordinatorReadingOptions.ForUploading to actually zip it up
      srcDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
      try fm.createDirectory(at: srcDir, withIntermediateDirectories: true, attributes: nil)
      let tmpURL = srcDir.appendingPathComponent(self.lastPathComponent)
      try fm.copyItem(at: self, to: tmpURL)
      srcDirIsTemporary = true
    }

    let coord = NSFileCoordinator()
    var readError: NSError?
    var copyError: NSError?
    var errorToThrow: NSError?

    var readSucceeded:Bool = false
    // coordinateReadingItemAtURL is invoked synchronously, but the passed in zippedURL is only valid
    // for the duration of the block, so it needs to be copied out
    coord.coordinate(readingItemAt: srcDir,
                     options: NSFileCoordinator.ReadingOptions.forUploading,
                     error: &readError)
    {
      (zippedURL: URL) -> Void in
      readSucceeded = true
      // assert: read succeeded
      do {
        try fm.copyItem(at: zippedURL, to: destURL)
      } catch let caughtCopyError {
        copyError = caughtCopyError as NSError
      }
    }

    if let theReadError = readError, !readSucceeded {
      // assert: read failed, readError describes our reading error
      NSLog("%@","zipping failed")
      errorToThrow =  theReadError
    }
    else if readError == nil && !readSucceeded  {
      NSLog("%@","NSFileCoordinator has violated its API contract. It has errored without throwing an error object")
      errorToThrow = NSError.init(domain: Bundle.main.bundleIdentifier!, code: 0, userInfo: nil)
    }
    else if let theCopyError = copyError {
      // assert: read succeeded, copy failed
      NSLog("%@","zipping succeeded but copying the zip file failed")
      errorToThrow = theCopyError
    }

    if srcDirIsTemporary {
      do {
        try fm.removeItem(at: srcDir)
      }
      catch {
        // Not going to throw, because we do have a valid output to return. We're going to rely on
        // the operating system to eventually cleanup the temporary directory.
        NSLog("%@","Warning. Zipping succeeded but could not remove temporary directory afterwards")
      }
    }
    if let error = errorToThrow { throw error }
    return destURL
  }
}

public extension Data {
  /// Creates a zip archive of this data via a temporary file and returns the zipped contents
  func zip() throws -> Data {
    let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    try self.write(to: tmpURL, options: Data.WritingOptions.atomic)
    let zipURL = try tmpURL.zip()
    let fm = FileManager.default
    let zippedData = try Data(contentsOf: zipURL, options: Data.ReadingOptions())
    try fm.removeItem(at: tmpURL) // clean up
    try fm.removeItem(at: zipURL)
      return zippedData as Data
  }
}
