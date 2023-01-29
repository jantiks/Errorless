import UIKit

public struct ErrorlesSDK {
    private let apiKey: String
    private let application: UIApplication
    
    public init(apiKey: String, application: UIApplication) {
        self.apiKey = apiKey
        self.application = application
    }
    
    public func initalizeSDK() {
        ErrorlesNotificationService().initalize()
        ErrorlessUISwizzlings().swizzle()
        AppDelegateSwizzlings(application).swizzle()
        ErrorlesNetworkManager.k_BASE_URL = apiKey
        ErrorlesCrashReporter().initalize()
    }
}
