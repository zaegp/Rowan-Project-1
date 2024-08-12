import UIKit
import FacebookLogin

class CartVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    private var products: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleCartProductAdded), name: .cartProductAdded, object: nil)
        fetchProducts()
        updateBadgeValue()
        
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.disableTabBarItem(at: 2)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        haveProducts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.enableTabBarItem(at: 2)
        }
    }
    
    
    // MARK: Actions
    @IBAction func navigationBarButtonTapped(_ sender: UIBarButtonItem) {
        let manager = LoginManager()
        manager.logOut()
    }
    
    @objc func handleCartProductAdded(notification: Notification) {
        
        fetchProducts()
        tableView.reloadData()
    }

    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "CartCell") as? CartCell else {
                    fatalError("Unable to dequeue CartCell")
                }
        
        let product = products[indexPath.row]
        tableViewCell.textField.isUserInteractionEnabled = false
        if product.stock == "1" {
            tableViewCell.rightButton.isEnabled = false
            tableViewCell.rightButton.alpha = 0.5
        } else {
            tableViewCell.rightButton.isEnabled = true
            tableViewCell.rightButton.alpha = 1
        }
        if products[indexPath.row].number == "1" {
            tableViewCell.leftButton.isEnabled = false
            tableViewCell.leftButton.alpha = 0.5
        } else {
            tableViewCell.leftButton.isEnabled = true
            tableViewCell.leftButton.alpha = 1
        }
        tableViewCell.mainImage.kf.setImage(with: URL(string: product.mainImage))
        tableViewCell.title.text = product.title
        tableViewCell.colorView.backgroundColor = UIColor(hex: product.color)
        tableViewCell.size.text = product.size
        tableViewCell.textField.text = "\(product.number)"
        tableViewCell.price.text = product.price
        tableViewCell.deleteButtonAction = { [weak self] in
            self?.deleteProduct(indexPath: indexPath)
        }
        
        tableViewCell.subtractAction = { [weak self] in
            self?.updateQuantity(at: indexPath, increment: false)
        }
        
        tableViewCell.addAction = { [weak self] in
            self?.updateQuantity(at: indexPath, increment: true)
        }
        
        return tableViewCell
    }
    
    
    // MARK: Cart Products
    private func haveProducts() {
        if products.count == 0 {
            button.setTitle("歡迎再次選購", for: .normal)
            button.setTitleColor(.white, for: .disabled)
            button.isEnabled = false
        } else {
            button.setTitle("前往結帳", for: .normal)
            button.isEnabled = true
        }
    }
    
    private func fetchProducts() {
        guard let context = context else {
                   print("Failed to get context: context is nil")
                   return
               }
        
        do {
            products = try context.fetch(Cart.fetchRequest())
            updateBadgeValue()
            self.tableView.reloadData()
        } catch {
            print("Failed to fetch context: \(error)")
        }
    }
    
    private func deleteProduct(indexPath: IndexPath) {
        guard let context = context else { return }
        
        context.delete(products[indexPath.row])
        products.remove(at: indexPath.row)
        updateBadgeValue()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.reloadData()
        
        do {
            try context.save()
        }
        catch {
            print("Failed to save context: \(error)")
        }
        haveProducts()
    }
    
    private func updateQuantity(at indexPath: IndexPath, increment: Bool) {
        let product = products[indexPath.row]
        guard var currentQuantity = Int(product.number) else { return }
        
        if increment {
            currentQuantity += 1
        } else if currentQuantity > 1 {
            currentQuantity -= 1
        }
        
        product.number = "\(currentQuantity)"
        products[indexPath.row] = product
        
        if let tableViewCell = tableView.cellForRow(at: indexPath) as? CartCell {
            tableViewCell.textField.text = "\(currentQuantity)"
            if currentQuantity >= Int(product.stock)! {
                tableViewCell.rightButton.isEnabled = false
                tableViewCell.rightButton.alpha = 0.5
            } else {
                tableViewCell.rightButton.isEnabled = true
                tableViewCell.rightButton.alpha = 1
            }
            if currentQuantity == 1{
                tableViewCell.leftButton.isEnabled = false
                tableViewCell.leftButton.alpha = 0.5
            } else {
                tableViewCell.leftButton.isEnabled = true
                tableViewCell.leftButton.alpha = 1
            }
        }
        do {
            try context?.save()
        }
        catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func updateBadgeValue() {
        if let tabBarController = self.tabBarController, let items = tabBarController.tabBar.items {
            let cartItemCount = products.count
            if let cartTabBarItem = items.first(where: { $0.tag == 2 }) {
                cartTabBarItem.badgeValue = cartItemCount > 0 ? "\(cartItemCount)" : nil
                cartTabBarItem.badgeColor = UIColor(red: 0.52, green: 0.35, blue: 0.20, alpha: 1.00)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .cartProductAdded, object: nil)
    }
}
