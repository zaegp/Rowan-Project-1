import UIKit
import FacebookLogin
import Alamofire
import KeychainAccess

let keychainManager = KeychainManager()

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FacebookManagerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    let orderImages = ["AwaitingPayment", "AwaitingShipment", "Shipped", "AwaitingReview", "Exchange"]
    let orderLabels = ["待付款", "待出貨", "待簽收", "待評價", "退換貨"]
    let otherImages = ["Starred", "Notification", "Refunded", "Address", "CustomerService", "SystemFeedback", "RegisterCellphone", "Settings"]
    let otherLabels = ["收藏", "貨到通知", "帳戶退款", "地址", "客服訊息", "系統回饋", "手機綁定", "設定"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            let facebookManager = FacebookManager()
            facebookManager.postFacebook()
            facebookManager.delegate = self
        }
        
        
        collectionView.collectionViewLayout = createFlowLayout(for: 0)
        collectionView.register(ProfileOrderHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileOrderHeader.identifier)
        collectionView.register(ProfileOtherHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileOtherHeader.identifier)
    }
    
    
    // MARK: User info
    func didReceiveUserInfo(name: String, picture: String) {
        DispatchQueue.main.async {
            self.nameLabel.text = name
            self.image.kf.setImage(with: URL(string: picture))
        }
    }

    
    // MARK: CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        if indexPath.section == 0 {
            collectionViewCell.orderImage.image = UIImage(named: orderImages[indexPath.item])
            collectionViewCell.orderLabel.text = orderLabels[indexPath.item]
            return collectionViewCell
        } else {
            collectionViewCell.orderImage.image = UIImage(named: otherImages[indexPath.item])
            collectionViewCell.orderLabel.text = otherLabels[indexPath.item]
            return collectionViewCell
        }
    }
    
    // MARK: Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileOrderHeader.identifier, for: indexPath) as! ProfileOrderHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileOtherHeader.identifier, for: indexPath) as! ProfileOtherHeader
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 70)
    }
    
    // MARK: CollectionView Flow LayOut
    func createFlowLayout(for section: Int) -> UICollectionViewFlowLayout {
        
        let flowLayout = UICollectionViewFlowLayout()
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        if section == 0 {
            let availableWidth = width - (padding * 2) - (minimumItemSpacing * 4)
            let itemWidth = availableWidth / 5
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            flowLayout.itemSize = CGSize(width: itemWidth, height: 50)
        } else {
            let availableWidth = width - (padding * 2) - (minimumItemSpacing * 3)
            let itemWidth = availableWidth / 4
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            flowLayout.itemSize = CGSize(width: itemWidth, height: 50)
        }
        
        return flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = createFlowLayout(for: indexPath.section)
        return layout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let layout = createFlowLayout(for: section)
        return layout.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let layout = createFlowLayout(for: section)
        return layout.minimumInteritemSpacing
    }
}
