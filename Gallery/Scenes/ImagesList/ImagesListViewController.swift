import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    
    
    @IBOutlet private var tableView: UITableView!
    
    private let ShowSingleImageSegueID = "ShowSingleImage"
    private let notificationCenter: NotificationCenter = .default
    private let imagesListService: ImageListService = ImageListService()
    private var imagesListObserver: NSObjectProtocol?
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagesListService.fetchPhotosNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeImagesListChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingImagesListChanges()
    }
    
    
    // When user tap on the cell
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            segue.identifier == ShowSingleImageSegueID,
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Not expected")
            return
        }
        
        let url = imagesListService.photos[indexPath.row].largeImage
        viewController.image = url
    }
}


// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueID, sender: indexPath)
    }
}


// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = imagesListService.photos.count
        print("COUNT = \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier , for: indexPath)
        guard let imagesListCell = cell as? ImagesListCell else {
            fatalError("ImageList cell error")
        }
        
        
        let photo = imagesListService.photos[indexPath.row]
        let url = photo.thumbnailImage
        
        imagesListCell.previewImage.kf.indicatorType = .activity
        imagesListCell.previewImage.kf.setImage(with: url, placeholder: UIImage(named: "stub"))
        
        let date = dateFormatter.string(from: photo.createdAt)
        imagesListCell.dateLabel.text = date
        
        imagesListCell.setLike(photo.isLiked)
        imagesListCell.delegate = self
        
        return imagesListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imagesListService.prepareForDisplay(index: indexPath.row)
    }
    
}


// MARK: - ImagesListCellDelegate


extension ImagesListViewController: imagesListCellDelegate {
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        
        
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.row < imagesListService.photos.count else {
            return
        }
        
        UIBlockingProgressHUD.show()
        
        let photo = imagesListService.photos[indexPath.row]
        let photoID = photo.id
        let isLiked = photo.isLiked
        
        imagesListService.changeLike(for: photoID, with: !isLiked) { error in
            
            UIBlockingProgressHUD.dismiss()

            if let error {
                assertionFailure("Like engine is broken :) \(error)")
                return
            } else {
                let image = !isLiked ? UIImage(named: "likeButton_isActive") : UIImage(named: "likeButton_isNotActive")
                
                DispatchQueue.main.async {
                    cell.likeButton.setImage(image, for: .normal)
                }
            }
        }
    }
}


// MARK: - Observe ImagesList Changes

extension ImagesListViewController {
    
    private func observeImagesListChanges() {
        imagesListObserver = notificationCenter.addObserver(
            forName: imagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func stopObservingImagesListChanges() {
        if let imagesListObserver {
            notificationCenter.removeObserver(imagesListObserver)
        }
    }
    private func updateTableViewAnimated() {
        
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = imagesListService.photos.count
        
        if oldCount < newCount {
            
            let newIndexPath = (oldCount..<newCount).map { IndexPath(row: $0, section: 0)
            }
            
            print("performBatchUpdates!!!")
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: newIndexPath, with: .automatic)
            }
        }
    }
}




