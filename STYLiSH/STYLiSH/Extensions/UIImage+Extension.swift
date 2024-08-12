import UIKit

enum ImageAsset: String {
    case Icons_24px_DropDown
}

extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
