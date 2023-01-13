import Foundation

enum FetchProfileError: Error {
    case dataError
    case decodingData
    case invalidResponse
}

final class ProfileService {
    
    let urlSession = URLSession.shared
    
    /// Fetch profile from the API
    /// - Parameters:
    ///   - token: The authentication token to be used in the request
    ///   - completion: A callback that will be called with the result of the API request
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        let url = K.defaultBaseURL!.appendingPathComponent("/me")
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            self.handleResponse(response, data: data, completion: completion)
            
        }.resume()
    }
    
    /// Handle the API response and check for errors
    /// - Parameters:
    ///   - response: The API response
    ///   - data: The data received in the response
    ///   - completion: A callback that will be called with the result of the API request
    
    func handleResponse(_ response: URLResponse?, data: Data?, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            DispatchQueue.main.async {
                completion(.failure(FetchProfileError.invalidResponse))
            }
            return
        }
        
        handleData(data, completion: completion)
        
    }
    
    /// Handle the received data from the API and decode it
    /// - Parameters:
    ///   - data: The data received from the API
    ///   - completion: A callback that will be called with the result of decoding the data
    
    func handleData(_ data: Data?, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let data = data {
            decodeData(data, completion: completion)
        } else {
            completion(.failure(FetchProfileError.dataError))
        }
    }
    
    /// Decode the received data from the API
    /// - Parameters:
    ///   - data: The data to be decoded
    ///   - completion: A callback that will be called with the result of decoding the data
    
    func decodeData(_ data: Data, completion: @escaping (Result<Profile, Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            let profileResult = try decoder.decode(ProfileResult.self, from: data)
            let profile = Profile(result: profileResult)
            completion(.success(profile))
        } catch {
            print("Decoding failed: \(error)")
            completion(.failure(FetchProfileError.decodingData))
        }
    }
}
