import UIKit

class CartCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var price: UILabel!
    
    var deleteButtonAction: (() -> Void)?
    var subtractAction: (() -> Void)?
    var addAction: (() -> Void)?
    
    @IBAction func deleteProduct(_ sender: Any) {
    }
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteButtonAction?()
    }
    @IBAction func subtract(_ sender: Any) {
        subtractAction?()
    }
    @IBAction func add(_ sender: Any) {
        addAction?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        textField.delegate = self
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00).cgColor
    }
}
