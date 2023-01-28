public struct ErrorlesSDK {
    private let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        
    }
    
    public func initalizeSDK() {
        ErrorlessNotificationService().initalize()
        ErrorlessUISwizzlings().swizzle()
        ErrorlessCrashReporter.k_BASE_URL = apiKey
        ErrorlessCrashReporter().initalize()
    }
}
