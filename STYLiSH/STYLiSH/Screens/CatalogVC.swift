import UIKit
import Kingfisher
import MJRefresh

enum Category {
    case women
    case men
    case accessories
}

class CatalogVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CatalogManagerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    @IBOutlet weak var accessoriesButton: UIButton!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewCenterXConstraint: NSLayoutConstraint!
    
    var womenProducts: [Product] = []
    var menProducts: [Product] = []
    var accessoriesProducts: [Product] = []
    var displayedProducts: [Product] = []
    var hasMoreProducts = true
    var page = 0
    var totalitems = 0
    var currentCategory: Category = .women
    let manager = CatalogManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        buttonStackView.subviews.forEach { button in
            if let uibutton = button as? UIButton {
                uibutton.addTarget(self, action: #selector(changePage(_:)), for: .touchUpInside)
            }
        }
        
        manager.delegate = self
        MJRefreshConfig.default.languageCode = "en"
        collectionView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadMoreData()
        })
    }
    
    
    // MARK: - Data Loading
    private func loadData() {
        switch currentCategory {
        case .women:
            self.manager.getWomenProducts(page: page)
        case .men:
            self.manager.getMenProducts()
        case .accessories:
            self.manager.getaccessoriesProducts()
        }
    }
    
    private func loadMoreData() {
        DispatchQueue.main.async {
            switch self.currentCategory {
            case .women:
                if self.hasMoreProducts == false {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.page += 1
                    self.manager.getWomenProducts(page: self.page)
                    self.collectionView.mj_footer?.endRefreshing()
                }
            case .men:
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            case .accessories:
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    
    // MARK: Network Manager Delegate
    func manager(_ manager: CatalogManager, didGet products: [Product]) {
        switch currentCategory {
        case .women:
            if page == 0 {
                totalitems = products[0].data.count
            } else {
                totalitems += products[0].data.count
            }
            if products[0].data.count < 6 {
                self.hasMoreProducts = false
            }
            self.womenProducts.append(contentsOf: products)
            displayedProducts = womenProducts
        case .men:
            menProducts.append(contentsOf: products)
            displayedProducts = menProducts
        case .accessories:
            accessoriesProducts.append(contentsOf: products)
            displayedProducts = accessoriesProducts
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func manager(_ manager: CatalogManager, didFailWith error: Error) {
            print("Network request failed: \(error.localizedDescription)")
            showErrorAlert(message: "Failed to load data. Please try again.")
        }
    
    
    // MARK: - Error Handling
        private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    
    // MARK: CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedProducts.reduce(0) { $0 + $1.data.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as? CatalogCell else {
            fatalError("Unexpected cell type")
        }
        
        switch currentCategory {
        case .women:
            collectionViewCell.productImage.kf.setImage(
                with: URL(string: womenProducts[indexPath.item / 6].data[indexPath.item % 6].main_image),
                options: [.cacheOriginalImage])
            collectionViewCell.productNameLabel.text = womenProducts[indexPath.item / 6].data[indexPath.item % 6].title
            collectionViewCell.productPriceLabel.text = String(womenProducts[indexPath.item / 6].data[indexPath.item % 6].price)
        case .men:
            collectionViewCell.productImage.kf.setImage(with: URL(string: menProducts[0].data[indexPath.item].main_image), options: [.cacheOriginalImage])
            collectionViewCell.productNameLabel.text = menProducts[0].data[indexPath.item].title
            collectionViewCell.productPriceLabel.text = String(menProducts[0].data[indexPath.item].price)
        case .accessories:
            collectionViewCell.productImage.kf.setImage(with: URL(string: accessoriesProducts[0].data[indexPath.item].main_image), options:[.cacheOriginalImage])
            collectionViewCell.productNameLabel.text = accessoriesProducts[0].data[indexPath.item].title
            collectionViewCell.productPriceLabel.text = String(accessoriesProducts[0].data[indexPath.item].price)
        }
        return collectionViewCell
    }
    
    
    // MARK: MJRefresh
    @objc private func refreshData() {
        switch self.currentCategory {
        case .women:
            self.page = 0
            self.totalitems = 0
            self.hasMoreProducts = true
            self.womenProducts.removeAll()
            self.loadData()
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.resetNoMoreData()
        case .men:
            self.menProducts.removeAll()
            self.loadData()
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.resetNoMoreData()
        case .accessories:
            self.accessoriesProducts.removeAll()
            self.loadData()
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.resetNoMoreData()
        }
    }
    
    
    // MARK: - Page Change
    @objc private func changePage(_ sender: UIButton) {
        underlineViewWidthConstraint.isActive = false
                underlineViewCenterXConstraint.isActive = false
                underlineViewTopConstraint.isActive = false
                
                underlineViewWidthConstraint = underlineView.widthAnchor.constraint(equalTo: sender.widthAnchor)
                underlineViewCenterXConstraint = underlineView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
                underlineViewTopConstraint = underlineView.topAnchor.constraint(equalTo: sender.bottomAnchor)
                
                underlineViewWidthConstraint.isActive = true
                underlineViewCenterXConstraint.isActive = true
                underlineViewTopConstraint.isActive = true
                
                UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                    self.view.layoutIfNeeded()
                }.startAnimation()
                
                updateButtonTintColor(for: sender)
                updateCategory(for: sender)
                refreshData()
    }

    private func updateButtonTintColor(for selectedButton: UIButton) {
        let selectedColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00)
        let defaultColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
        
        womenButton.tintColor = (selectedButton == womenButton) ? selectedColor : defaultColor
        menButton.tintColor = (selectedButton == menButton) ? selectedColor : defaultColor
        accessoriesButton.tintColor = (selectedButton == accessoriesButton) ? selectedColor : defaultColor
    }

    private func updateCategory(for selectedButton: UIButton) {
        if selectedButton == womenButton {
            currentCategory = .women
        } else if selectedButton == menButton {
            currentCategory = .men
        } else if selectedButton == accessoriesButton {
            currentCategory = .accessories
        }
    }

    
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail", let indexPath = collectionView.indexPathsForSelectedItems?.first {
            let productDetailVC = segue.destination as! ProductDetailVC
            let product = displayedProducts[0].data[indexPath.item]
            productDetailVC.productDetail = product
        }
    }
}
