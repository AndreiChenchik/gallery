import Foundation

struct K {
    
    // First account
    static let accessKey = "45V_47NAE3YXOsxEma47rlcGz8W9gJQKwM68gqIGcjo"
    static let secretKey = "Iuk0CV-2rMm4MSaTUvQ3UzPfWb1xdCsPHpe9u-FjUTc"
    
    // Second account (if there're no limits)
//    static let accessKey = "z2VYT0g1D8R5nrW5l4nnxw5bpGhZmcLfVH5Q2QUqSSo"
//    static let secretKey = "Trirf9j27yJ5VZS1t8Z1KgeKBDSX4vsFpgAhTi0X2U4"
    
    static let redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseAPIURL = URL(string: "https://api.unsplash.com")
    static let defaultBaseURL = URL(string: "https://unsplash.com")
    
    static let authURL = "https://unsplash.com/oauth/authorize"
    static let authURLPath = "/oauth/authorize"
    
    static let tokenURL = "https://unsplash.com/oauth/tokenS"
    static let tokenURLPath = "/oauth/token"
    
    static let photosURLPath = "/photos"
    
}
