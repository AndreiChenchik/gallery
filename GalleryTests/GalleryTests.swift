@testable import Gallery
import XCTest

final class WebViewTests: XCTestCase {
    
    
    // MARK: - AUTH TESTS
    
    
    // The WebViewVC calls the presenter's viewDidLoad method.
    // Let's check that this is really happening.
    
    func testVCCallsViewDidLoad() {
        
        /// given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebViewVC") as? WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        vc?.presenter = presenter
        
        /// when
        let _ = vc?.view
        
        /// than
        XCTAssertTrue(presenter.viewDidLoadCalled)
        
    }
    
    // Check whether the presenter calls the loadRequest() method
    // of the VC after the call.viewDidLoad()
    
    func testPresenterCallsLoadRequest() {
        
        /// given
        let vc = WebViewVCSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        vc.presenter = presenter
        presenter.view = vc
        
        /// when
        presenter.viewDidLoad()
        
        /// then
        XCTAssertTrue(vc.loadRequestCalled)
        
    }
    
    // Make sure that the presenter's shouldHideProgress method
    // is working properly
    
    func testProgressBarVisibleWhenProgressValueLessThenOne() {
        
        /// given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.5
        
        /// when
        let shouldHideProgress: Bool = presenter.shouldHideProgress(for: progress)
        
        /// then
        XCTAssertFalse(shouldHideProgress)
        
    }
    
    // Make sure that progressBar value == 1 the shouldHideProgress
    // returns true.
    
    func testProgressBarHiddenWhenProgressValueIsOne() {
        
        /// given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        /// when
        let shouldHideProgress: Bool = presenter.shouldHideProgress(for: progress)
        
        /// then
        XCTAssertTrue(shouldHideProgress)
    }
    
    // Сheck that the URL received from authURL contains all
    // the necessary components.
    
    func testAuthHelperAuthURL() {
        
        /// given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        /// when
        let url = authHelper.authURL()
        let urlString = url.absoluteString

        /// then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        
    }
    
    // Check that AuthHelper gets correct code from the URL
    
    func testCodeFromURL() {
        
        /// given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        // when
        let code = authHelper.code(from: url)
        
        // then
        XCTAssertEqual(code, "test code")
        
    }
    
}
