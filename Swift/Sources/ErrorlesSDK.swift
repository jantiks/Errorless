public struct ErrorlesSDK {
    private let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func initalizeSDK() {
        ErrorlesNotificationService().initalize()
        ErrorlessUISwizzlings().swizzle()
        AppDelegateSwizzlings().swizzle()
        ErrorlesNetworkManager.k_BASE_URL = apiKey
        ErrorlesCrashReporter().initalize()
    }
}
