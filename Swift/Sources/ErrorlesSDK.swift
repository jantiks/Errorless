import UIKit

public struct ErrorlesSDK {
    private let apiKey: String
    
    public init(apiKey: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.apiKey = apiKey
    }
    
    public func initalizeSDK() {
        ErrorlesNotificationService().initalize()
        ErrorlessUISwizzlings().swizzle()
        AppDelegateSwizzlings().swizzle()
        if #available(iOS 13.0, *) {
            SceneDelegateSwizzlings().swizzle()
        }
        ErrorlesNetworkManager.k_BASE_URL = apiKey
        ErrorlesCrashReporter().initalize()
    }
}
