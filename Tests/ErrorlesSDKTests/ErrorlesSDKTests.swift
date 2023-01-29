import XCTest
@testable import ErrorlesSDK

final class ErrorlesSDKTests: XCTestCase {
    func testTrackEvents() throws {
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get profile
        ErrorlessTracker().track(.viewDidLoad) { result in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
}
