import Gallery
import Foundation

final class WebViewVCSpy: WebViewViewControllerProtocol {
    
    var presenter: Gallery.WebViewPresenterProtocol?
    var loadRequestCalled = false
    
    func load(with request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) { }
    func setProgressHidden(_ isHidden: Bool) { }
}
