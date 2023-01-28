import UIKit
import Kingfisher


protocol imagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: imagesListCellDelegate?
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func likeButton(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImage.kf.cancelDownloadTask()
    }
    
    func setLike(_ isLiked: Bool) {
        
        let image = isLiked ? UIImage(named: "likeButton_isActive") :
            UIImage(named: "likeButton_isNotActive")

        likeButton.setImage(image, for: .normal)
    }    
}


