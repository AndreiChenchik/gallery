import Foundation

enum FetchProfileImageError: String, Error {
    case invalidResponse
    case dataError
    case noImageDataFound
    case decodingData
}

final class ProfileImageService {
    
    private let session = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    static let shared = ProfileImageService() // Singleton
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange") // Notification name

    private let tokenStorage = OAuth2TokenStorage()
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        let token = tokenStorage.token
        
        var request = URLRequest.makeHTTPRequest(
            path: "/users/\(username)",
            httpMethod: "GET",
            baseURL: K.defaultBaseAPIURL
        )
        
        if let token {
             request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         } else {
             completion(.failure(TokenStorageError.tokenNotFound))
             return
         }
        
        
        task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let profileImageResult):
                            
                guard let avatarURL = profileImageResult.profileImage.medium else {
                    completion(.failure(FetchProfileImageError.noImageDataFound))
                    return
                }
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                
                print("AVATAR URL: \(avatarURL)")
                
                NotificationCenter.default.post(name: ProfileImageService.DidChangeNotification, object: self, userInfo: ["URL": avatarURL])
            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
