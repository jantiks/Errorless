import UIKit

public struct ErrorlesSDK {
    private let apiKey: String
    
    public init(apiKey: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.apiKey = apiKey
    }
    
    public func initalizeSDK() {
        ErrorlessUISwizzlings().swizzle()
        AppDelegateSwizzlings().swizzle()
        SharedObserver.shared.initalize()
        ErrorlesNetworkManager.k_BASE_URL = apiKey
        ErrorlesCrashReporter().initalize()
    }
}
