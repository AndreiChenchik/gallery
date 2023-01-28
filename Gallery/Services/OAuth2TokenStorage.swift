import Foundation
import SwiftKeychainWrapper
import WebKit


enum TokenStorageError: String, Error {
    case tokenNotFound
    case newValueError
}


struct OAuth2TokenStorage {
    
    private let tokenKey = "BearerToken"

    var token: String? {
        
        set {
            
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                return
            }
            
        }
        get { return KeychainWrapper.standard.string(forKey: tokenKey) }
        
    }
    
    func updateToken(with newValue: String?) {
        
        if let newValue = newValue {
            
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            
        } else {
            return
        }
    }
}
