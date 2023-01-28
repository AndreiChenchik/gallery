import UIKit
import Kingfisher
import WebKit


final class ProfileViewController: UIViewController {
    
    
    private let token = OAuth2TokenStorage().token
    
    let avatar = UIImageView()
    let nameLabel = UILabel()
    let loginNameLabel = UILabel()
    let descriptionLabel = UILabel()
    let logoutButton = UIButton()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfile()
        addObserverForNotifications()
        updateAvatar()
    }
    
    
    @objc private func logoutButtonTapped() {
        
        let alert = AlertService()
        alert.showLogoutAlert(on: self) {
            
            var tokenStorage = OAuth2TokenStorage()
            CookieCleanerService.clean()
            tokenStorage.token = nil
            
            let startViewController = SplashViewController()
            
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("can't find app")
                return
            }
            window.rootViewController = startViewController
        }
    }
}


// MARK: - UI

private extension ProfileViewController {
    
    func setupUI() {
        
        // MARK: - SETUP UI
        
        view.backgroundColor = UIColor.blackYP
        setAvatar()
        setNameLabel()
        setLoginNameLabel()
        setLoginNameLabel()
        setDescription()
        setLogoutButton()
        setConstraints()
        
        
        func setAvatar() {
            
            let profileImage = UIImage(named: "UserPic")
            
            avatar.image = profileImage
            avatar.layer.cornerRadius = 35
            avatar.clipsToBounds = true
            avatar.contentMode = .scaleAspectFill
            
            avatar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(avatar)
        }
        
        
        func setNameLabel() {
            
            nameLabel.text = "Name"
            
            nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
            nameLabel.textColor = UIColor.whiteYP
            
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nameLabel)
    
        }
        
        
        func setLoginNameLabel() {
            
            loginNameLabel.text = "@username"
            
            loginNameLabel.font = UIFont.boldSystemFont(ofSize: 13)
            loginNameLabel.textColor = UIColor.grayYP
            
            loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loginNameLabel)
            
        }
        
        
        func setDescription() {
            
            descriptionLabel.text = "Biography"
            
            descriptionLabel.font = UIFont.systemFont(ofSize: 13)
            descriptionLabel.textColor = UIColor.whiteYP
            
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(descriptionLabel)
            
        }
        
        
        func setLogoutButton() {
            
            let image = UIImage(named: "logout_icon")
            
            logoutButton.setBackgroundImage(image, for: .normal)
            logoutButton.tintColor = UIColor.redYP
            
            logoutButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(logoutButton)
            
            logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        }
        
        
        // Constraints
        
        func setConstraints() {
            
            /// Avatar
            avatar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
            avatar.widthAnchor.constraint(equalToConstant: 70).isActive = true
            avatar.heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            /// Name
            nameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            nameLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8).isActive = true
            
            /// Login
            loginNameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
            
            /// Bio/Description
            descriptionLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
            
            /// Logout Button
            logoutButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        }
    }
}


// MARK: - Adding an observer

extension ProfileViewController {
    
    private func addObserverForNotifications() {
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        )
    }
}

// MARK: - UI updates section


extension ProfileViewController {
    
    private func updateProfile() {
        
        let profileService = ProfileService.shared
        let profile = profileService.profile
        
        nameLabel.text = profile?.name
        loginNameLabel.text = profile?.loginName
        descriptionLabel.text = profile?.bio
        
    }
    
    
    func updateAvatar() {
        
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
                
        else {
            print("Error creating URL with profileImageURL = \(String(describing: ProfileImageService.shared.avatarURL))")
            return
        }
        
        DispatchQueue.main.async {
            
            
            // For debugging
            /*
             let cache = ImageCache.default
             cache.clearMemoryCache()
             cache.clearDiskCache()
             */
            
            self.avatar.kf.indicatorType = .activity
            self.avatar.kf.setImage(with: url, placeholder: UIImage(named: "placeholder.svg"))
        }
    }
}


