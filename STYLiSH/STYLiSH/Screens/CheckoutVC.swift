import UIKit
import TPDirect
import FacebookLogin
import CoreData

class CheckoutVC: UIViewController, STOrderUserInputCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBAction func navigationBarButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    private var products: [Cart] = []
    let header = ["結帳商品", "收件資訊", "付款詳情"]
    var userInput = UserInput(name: "", email: "", phoneNumber: "", address: "", shipTime: "")
    var tpdForm : TPDForm!
    var tpdCard : TPDCard!
    var checkoutButton: UIButton?
    var prime = ""
    var color = [String].self
    lazy var list: [[String: Any]] = [["id": "", "name": "", "price": 1, "color": ["", ""], "size": "", "qty": 1]]
    var checkoutManager = CheckoutManager()
    var subtotal = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProductsFromCoreData()
        setupTableView()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderProductCell.self), bundle: nil)
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderUserInputCell.self), bundle: nil)
        tableView.lk_registerCellWithNib(identifier: String(describing: STPaymentInfoTableViewCell.self), bundle: nil)
        
        let headerXib = UINib(nibName: String(describing: STOrderHeaderView.self), bundle: nil)
        tableView.register(headerXib, forHeaderFooterViewReuseIdentifier: String(describing: STOrderHeaderView.self))
    }
}

extension CheckoutVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 67.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: STOrderHeaderView.self)) as? STOrderHeaderView else {
            return nil
        }
        
        headerView.titleLabel.text = header[section]
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        
        footerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "cccccc")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return products.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderProductCell.self), for: indexPath)
            if let productCell = cell as? STOrderProductCell {
                productCell.productImageView.kf.setImage(with: URL(string:products[indexPath.row].mainImage))
                productCell.productTitleLabel.text = products[indexPath.row].title
                productCell.colorView.backgroundColor = UIColor(hex: products[indexPath.row].color)
                productCell.productSizeLabel.text = products[indexPath.row].size
                productCell.priceLabel.text = products[indexPath.row].price
                productCell.orderNumberLabel.text = products[indexPath.row].number
                if indexPath.row >= 1 && list.count <= indexPath.row {
                    let listItem: [String: Any] = [
                        "id": products[indexPath.row].id,
                        "name": products[indexPath.row].title,
                        "price": Int(products[indexPath.row].price) ?? 0,
                        "color": [products[indexPath.row].color, products[indexPath.row].colorName],
                        "size": products[indexPath.row].size,
                        "qty": Int(products[indexPath.row].number) ?? 0
                    ]
                    list.append(listItem)
                } else {
                    list[0]["id"] = products[indexPath.row].id
                    list[0]["name"] = products[0].title
                    list[0]["price"] = Int(products[0].price)
                    list[0]["color"] = [products[0].color, products[0].colorName]
                    list[0]["size"] = products[0].size
                    list[0]["qty"] = Int(products[0].number)
                }
                subtotal += Int(products[indexPath.row].price) ?? 0
                
                return productCell
            }
            
            
        } else if indexPath.section == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderUserInputCell.self), for: indexPath)
            
            if let userInputCell = cell as? STOrderUserInputCell {
                userInputCell.delegate = self
            }
            
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STPaymentInfoTableViewCell.self), for: indexPath)
            
            
            if let paymentCell = cell as? STPaymentInfoTableViewCell {
                paymentCell.delegate = self
                self.checkoutButton = paymentCell.checkoutButton
                
                paymentCell.layoutCellWith(productPrice: subtotal, shipPrice: 60, productCount: products.count)
                
                tpdForm = TPDForm.setup(withContainer: paymentCell.creditView)
                
                tpdForm.setErrorColor(UIColor.red)
                tpdForm.setOkColor(UIColor.green)
                tpdForm.setNormalColor(UIColor.black)
                tpdForm.onFormUpdated { [weak self] status in
                    self?.updateCheckoutButtonState(isFormValid: status.isCanGetPrime())
                }
                self.tpdCard = TPDCard.setup(self.tpdForm)
            }
        }
        
        return cell
    }
    
    // MARK: STOrderUserInputCellDelegate
    func didChangeUserData(_ cell: STOrderUserInputCell, username: String, email: String, phoneNumber: String, address: String, shipTime: String) {
        userInput.name = username
        userInput.email = email
        userInput.phoneNumber = phoneNumber
        userInput.address = address
        userInput.shipTime = shipTime
        
        let isFormValid = !username.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && !address.isEmpty
        updateCheckoutButtonState(isFormValid: isFormValid)
    }
    
    private func updateCheckoutButtonState(isFormValid: Bool) {
        guard let button = self.checkoutButton else { return }
        
        if isFormValid && isUserDataComplete() {
            button.isEnabled = true
            button.backgroundColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00)
        } else {
            button.isEnabled = false
            button.backgroundColor = UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.00)
        }
    }
    
    private func isUserDataComplete() -> Bool {
        return !userInput.name.isEmpty &&
        !userInput.email.isEmpty &&
        !userInput.phoneNumber.isEmpty &&
        !userInput.address.isEmpty
    }
    
    func loadProductsFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        
        do {
            if let fetchedProducts = try context.fetch(fetchRequest) as [Cart]? {
                products = fetchedProducts
                tableView.reloadData()
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
}

extension CheckoutVC: STPaymentInfoTableViewCellDelegate {
    
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell) {
        tableView.reloadData()
    }
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    ) {
        print(payment, cardNumber, dueDate, verifyCode)
    }
    
    func checkout(_ cell:STPaymentInfoTableViewCell) {
        CheckoutVC.clearCoreData()
        tpdCard.onSuccessCallback { [weak self] (prime, cardInfo, cardIdentifier, merchantReferenceInfo) in
                guard let self = self, let prime = prime else {
                    print("Failed to get prime")
                    return
                }
                
                print("Prime : \(prime), LastFour : \(String(describing: cardInfo?.lastFour)), CardIdentifier: \(String(describing: cardIdentifier)), MerchantReferenceInfo: \(merchantReferenceInfo)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.someMethodToPassData(prime: prime)
                }
            }.onFailureCallback { (status, message) in
                print("Status : \(status), Message : \(message)")
            }
            
            tpdCard.getPrime()
        print("=============")
        print("User did tap checkout button")
        
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            let facebookManager = FacebookManager()
            facebookManager.postFacebook()
            performSegue(withIdentifier: "showSuccess", sender: self)
        } else {
            performSegue(withIdentifier: "showLogin", sender: self)
        }
    }
    
    static func clearCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let persistentContainer = appDelegate.persistentContainer
        
        guard let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else { return }
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            try persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            print("Error resetting persistent store: \(error)")
        }
    }
    
}

extension CheckoutVC: CheckoutManagerDelegate {
    func didProvideOrderData(parameters: [String : Any]) {
        checkoutManager.parameters = parameters
        checkoutManager.postOrder()
    }
    
    
    
    func someMethodToPassData(prime: String) {
        let parameters: [String: Any] = [
            "prime": prime,
            "order": [
                "shipping": "delivery",
                "payment": "credit_card",
                "subtotal": subtotal,
                "freight": 60.00,
                "total": subtotal + 60,
                "recipient": [
                    "name": userInput.name,
                    "phone": userInput.phoneNumber,
                    "email": userInput.email,
                    "address": userInput.address,
                    "time": userInput.shipTime
                ],
                "list": list
            ]
        ]
        
        didProvideOrderData(parameters: parameters)
    }
    
    
}
