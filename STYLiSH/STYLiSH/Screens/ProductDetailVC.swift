import UIKit
import CoreData
import StatusAlert

let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

class ProductDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    @IBAction func navigationBarButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    var productDetail: Products?
    var addToCartArray: [String] = []
    private let blackView = UIView()
    private let footerButton = UIButton(type: .system)
    private var subTableView: UITableView?
    var targetCell: AddToCartCell?
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupFooterButton()
    }
    
    private func setupUI() {
        setupBlackView()
        setupTableHeaderView()
        adjustSafeAreaInsets()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        setupNavigationBarAppearance(isOpaque: false)
        setupFooterView()
    }
    
    private func setupBlackView() {
        blackView.backgroundColor = .black
        blackView.alpha = 0.5
        blackView.isHidden = true
        tableView.addSubview(blackView)
        
        blackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackView.topAnchor.constraint(equalTo: view.topAnchor),
            blackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableHeaderView() {
        let headerView = CollectionTableHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 500))
        headerView.images = productDetail?.images ?? []
        headerView.collectionView.reloadData()
        tableView.tableHeaderView = headerView
    }
    
    private func setupNavigationBarAppearance(isOpaque: Bool) {
        let appearance = UINavigationBarAppearance()
        if isOpaque {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
        } else {
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
        }
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupFooterView() {
        footerView.backgroundColor = .white
        footerView.layer.borderColor = UIColor.gray.cgColor
        footerView.layer.borderWidth = 1.0
        footerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupFooterButton() {
        footerButton.setTitle("加入購物車", for: .normal)
        footerButton.tintColor = .white
        footerButton.backgroundColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(footerButton)
        
        NSLayoutConstraint.activate([
            
            footerButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            footerButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16),
            footerButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            footerButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16)
        ])
        
        footerButton.addTarget(self, action: #selector(addSubview), for: .touchUpInside)
    }
    
    
    func showSuccessAlert() {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Icons_44px_Success01")
        statusAlert.message = "success"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.translatesAutoresizingMaskIntoConstraints = false
        statusAlert.appearance.backgroundColor = .black
        statusAlert.appearance.tintColor = .white
        statusAlert.alpha = 0.5
        let sizesAndDistances = statusAlert.sizesAndDistances
        sizesAndDistances.imageToMessageSpace = 0
        sizesAndDistances.imageWidth = 36
        
        NSLayoutConstraint.activate([
            statusAlert.widthAnchor.constraint(equalToConstant: 123),
            statusAlert.heightAnchor.constraint(equalToConstant: 123)
        ])
        
        statusAlert.showInKeyWindow()
    }
    
    // MARK: Subview
    @objc func addSubview() {
        guard let productDetail = productDetail else { return }
        
        if subTableView == nil {
            setupSubTableView(productDetail: productDetail)
        } else {
            subTableView?.removeFromSuperview()
            subTableView = nil
            footerButton.isEnabled = true
            blackView.isHidden = true
            showSuccessAlert()
            addToCartArray = targetCell?.passData() ?? []
            createProduct()
            NotificationCenter.default.post(name: .cartProductAdded, object: nil)
        }
    }
    
    private func setupSubTableView(productDetail: Products) {
        blackView.isHidden = false
        footerButton.isEnabled = false
        
        let subTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.5), style: .plain)
        subTableView.dataSource = self
        subTableView.delegate = self
        subTableView.register(AddToCartCell.self, forCellReuseIdentifier: "AddToCartCell")
        subTableView.layer.borderColor = UIColor.gray.cgColor
        subTableView.layer.borderWidth = 1.0
        subTableView.translatesAutoresizingMaskIntoConstraints = false
        subTableView.separatorStyle = .none
        
        let headerView = AddToCartHeader(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 98))
        headerView.setupView(title: productDetail.title, price: productDetail.price)
        subTableView.tableHeaderView = headerView
        
        headerView.onCloseButtonTapped = { [weak self] in
            self?.subTableView?.removeFromSuperview()
            self?.footerButton.isEnabled = true
            self?.blackView.isHidden = true
            self?.subTableView = nil
        }
        
        view.addSubview(subTableView)
        
        subTableView.transform = CGAffineTransform(translationX: 0, y: footerView.frame.height)
        UIView.animate(withDuration: 0.3) {
            subTableView.transform = .identity
        }
        
        NSLayoutConstraint.activate([
            subTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subTableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            subTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        self.subTableView = subTableView
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        adjustSafeAreaInsets()
    }
    
    private func adjustSafeAreaInsets() {
        if let windowScene = view.window?.windowScene {
            let topPadding = windowScene.windows.first?.safeAreaInsets.top ?? 0
            self.additionalSafeAreaInsets.top = -topPadding
            tableView.contentInset = UIEdgeInsets(top: -topPadding, left: 0, bottom: 0, right: 0)
        }
    }
    
    
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == subTableView {
            return 300
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == subTableView {
            return 1
        } else {
            return 9
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == subTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCartCell", for: indexPath) as! AddToCartCell
            targetCell = cell
            cell.addColorChart(colors: productDetail?.colors ?? [])
            cell.addSizeChart(sizes: productDetail?.sizes ?? [])
            cell.setupTextField()
            cell.setVariants(variants: productDetail?.variants ?? [])
            cell.enableCartButton = { [weak self]  in
                self?.footerButton.isEnabled = true
            }
            cell.disableCartButton = { [weak self] in
                self?.footerButton.isEnabled = false
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "DetailDescriptionCell") as! DetailDescriptionCell
            cell.label.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
            
            guard let productDetail = productDetail else {
                cell.label.text = "Error"
                return cell
            }
            
            switch indexPath.row {
            case 0:
                if let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailTitleCell") as? DetailTitleCell {
                    tableViewCell.id.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
                    tableViewCell.title.text = productDetail.title
                    tableViewCell.id.text = String(productDetail.id)
                    tableViewCell.price.text = "NT$ " + String(productDetail.price)
                    return tableViewCell
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailStoryCell") as! DetailStoryCell
                cell.label.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
                cell.label.text = productDetail.story
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailColorCell") as! DetailColorCell
                cell.addColorChart(colors: productDetail.colors)
                cell.label.text = "顏色  |"
                cell.label.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
                
                return cell
            default:
                switch indexPath.row {
                case 3:
                    cell.label.text = "尺寸  |"
                    cell.detailLabel.text = productDetail.sizes.joined(separator: " - ")
                case 4:
                    cell.label.text = "庫存  |"
                    cell.detailLabel.text = String(productDetail.variants.reduce(0) { $0 + $1.stock })
                case 5:
                    cell.label.text = "材質  |"
                    cell.detailLabel.text = productDetail.texture
                case 6:
                    cell.label.text = "洗滌  |"
                    cell.detailLabel.text = productDetail.wash
                case 7:
                    cell.label.text = "產地  |"
                    cell.detailLabel.text = productDetail.place
                case 8:
                    cell.label.text = "備註  |"
                    cell.detailLabel.text = productDetail.note
                default:
                    cell.label.text = "Error"
                }
            }
            return cell
        }
    }
    
    func handleReturnedData(data: [String]) {
        print("返回的数据：\(data)")
    }
    
    
    // MARK: Save Data
    func createProduct() {
        guard let context = context else {
            print("Unable to retrieve context")
            return
        }
        
        guard let productDetail = productDetail,
              addToCartArray.count >= 5 else {
            print("Product details or cart array is missing")
            return
        }
        
        let newProduct = Cart(context: context)
        
        newProduct.setValue(productDetail.main_image, forKey: "mainImage")
        newProduct.setValue(productDetail.title, forKey: "title")
        newProduct.setValue(addToCartArray[0], forKey: "color")
        newProduct.setValue(addToCartArray[1], forKey: "size")
        newProduct.setValue(addToCartArray[2], forKey: "number")
        newProduct.setValue(addToCartArray[3], forKey: "stock")
        newProduct.setValue(String(productDetail.price), forKey: "price")
        newProduct.setValue(addToCartArray[4], forKey: "colorName")
        newProduct.setValue(String(productDetail.id), forKey: "id")
        do {
            try context.save()
        }
        catch {
            print("Failed to save product: \(error)")
        }
    }
    
    func fetchCartProducts() -> [Cart] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        
        do {
            let cartProducts = try context.fetch(fetchRequest)
            return cartProducts
        } catch {
            print("Failed to fetch cart products: \(error)")
            return []
        }
    }
}

extension Notification.Name {
    static let cartProductAdded = Notification.Name("cartProductAdded")
}

