import Foundation

enum FetchPhotoError: String, Error {
    case noPhotoData
    case photoNotExists
}


final class ImageListService {
    
    private var task: URLSessionTask?
    private let session = URLSession.shared
    
    
    private let notificationCenter: NotificationCenter = .default
    let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    
    private let tokenStorage = OAuth2TokenStorage()
    private (set) var photos: [Photo] = [] {
        didSet { notificationCenter.post(name: didChangeNotification, object: self) }
    }
    
    private var lastLoadedPage: Int?
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    func prepareForDisplay(index: Int) {
        guard index == photos.count - 1, task == nil else {
            return
        }
        fetchPhotosNextPage()
    }
    
    
    
    // MARK: - Service
    
    func fetchPhotosNextPage() {
        
        let token = tokenStorage.token
        
        let nextPage: Int

        if let lastLoadedPage {
          nextPage = lastLoadedPage + 1
        } else {
           nextPage = 1
        }

        guard let token = token else {
            print(TokenStorageError.tokenNotFound)
            return
        }
        
        
        let request = photoRequest(with: token, page: nextPage)
        
        task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
                
            case let .success(photoResults):
                let photos = photoResults.map {
                    $0.convertToViewModel(formatter: self.dateFormatter)
                }
                print("Task succeeded")
                print("PHOTO DATE: \(photos[1].createdAt)")
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.photos += photos
                    self.lastLoadedPage = nextPage + 1
                }
                
            case let .failure(error):
                print("Task error: \(error.localizedDescription)")
            }
            self.task = nil
        }
    }
}


private extension ImageListService {
    
    func photoRequest(with token: String, page: Int) -> URLRequest {
        
        var request = URLRequest.makeHTTPRequest(
            path: K.photosURLPath,
            httpMethod: "GET",
            baseURL: K.defaultBaseAPIURL
        )
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "order_by", value: "popular")
        ]
        request.url = components.url
        print("REQUEST: \(request)")
        return request
    }
}



extension ImageListService {
    func changeLike(for photoID: String, with isLiked: Bool, _ completion: @escaping (Error?) -> Void) {
        guard let token = OAuth2TokenStorage().token else {
            completion(TokenStorageError.tokenNotFound)
            return
        }
        
        var request = URLRequest.makeHTTPRequest(
            path: K.photosURLPath + "/\(photoID)/like",
            httpMethod: isLiked ? "POST" : "DELETE",
            baseURL: K.defaultBaseAPIURL
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
    
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                DispatchQueue.main.async {
                    completion(error ?? NetworkError.urlSessionError)
                }
                return
            }
            
            if let _ = error {
                DispatchQueue.main.async {
                    completion(NetworkError.urlSessionError)
                }
            } else {
                if let index = self.photos.firstIndex(where: { $0.id == photoID }) {
                    var newPhoto = self.photos[index]
                    newPhoto.isLiked = isLiked
                    self.photos[index] = newPhoto
                }
                completion(nil)
            }
        }
        task.resume()
    }
}


private extension PhotoResult {
    func convertToViewModel(formatter: ISO8601DateFormatter) -> Photo {
        Photo(
            id: self.id,
            description: self.description,
            thumbnailImage: self.urls.small,
            largeImage: self.urls.full,
            size: .init(
                width: self.width,
                height: self.height
            ),
            createdAt: formatter.date(from: self.createdAt) ?? Date(),
            isLiked: self.likedByUser
        )
    }
}
