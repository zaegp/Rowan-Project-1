import UIKit
import Kingfisher
import MJRefresh


class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    private var products: [Cart] = []
    var marketingHots: [Hots] = []
    var headerSection = 0
    let manager = MarketManager()

    private enum CellIdentifier: String {
        case oneImage = "OneImageCell"
        case fourImages = "FourImagesCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getProducts()
        manager.delegate = self
        manager.getMarketingHots()
    }
    
    private func setupTableView() {
        MJRefreshConfig.default.languageCode = "en"
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !marketingHots.isEmpty else {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifier.oneImage.rawValue) as! OneImageCell
        }

        let product = marketingHots[0].data[indexPath.section].products[indexPath.row]
        let cellIdentifier: CellIdentifier = indexPath.row % 2 != 0 ? .fourImages : .oneImage
        guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue) else {
            return UITableViewCell()
        }

        if let cell = tableViewCell as? FourImagesCell {
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.description
            cell.productImage1.kf.setImage(with: URL(string: product.images[0]), options: [.cacheOriginalImage]) { result in
                if case .failure(let error) = result {
                    print("Failed to load image: \(error)")
                    cell.productImage1.image = UIImage(named: "defaultImage")
                    
                }
            }
            cell.productImage2.kf.setImage(with: URL(string: product.images[1]), options: [.cacheOriginalImage]) { result in
                if case .failure(let error) = result {
                    print("Failed to load image: \(error)")
                    cell.productImage1.image = UIImage(named: "defaultImage")
                }
            }
            cell.productImage3.kf.setImage(with: URL(string: product.images[2]), options: [.cacheOriginalImage]) { result in
                if case .failure(let error) = result {
                    print("Failed to load image: \(error)")
                    cell.productImage1.image = UIImage(named: "defaultImage")
                }
            }
            cell.productImage4.kf.setImage(with: URL(string: product.images[1]), options: [.cacheOriginalImage]) { result in
                if case .failure(let error) = result {
                    print("Failed to load image: \(error)")
                    cell.productImage1.image = UIImage(named: "defaultImage")
                }
            }
        } else if let cell = tableViewCell as? OneImageCell {
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.description
            cell.productImage.kf.setImage(with: URL(string: product.main_image), options: [.cacheOriginalImage]) { result in
                if case .failure(let error) = result {
                    print("Failed to load image: \(error)")
                    cell.productImage.image = UIImage(named: "defaultImage")
                }
            }
        }

        return tableViewCell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }

    // MARK: Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !marketingHots.isEmpty else { return nil }

        let headerView = UIView()
        headerView.backgroundColor = .white

        let headerLabel = UILabel()
        headerLabel.text = marketingHots[0].data[section].title
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)

        let headerLabelPadding = (UIScreen.main.bounds.width - 343) / 2

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: headerLabelPadding),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // MARK: MJRefresh
    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.manager.getMarketingHots()
            self.tableView.mj_header?.endRefreshing()
        }
    }

    // MARK: Pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = sender as? IndexPath {
                let productDetailVC = segue.destination as! ProductDetailVC
                let selectedHot = marketingHots[0].data[indexPath.section].products[indexPath.row]
                productDetailVC.productDetail = selectedHot
            }
        }
    }

    // MARK: Cart Items
    func getProducts() {
        do {
            if let context = context {
                        products = try context.fetch(Cart.fetchRequest())
                        updateBadgeValue()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Failed to get context: context is nil")
                    }
        } catch {
            showErrorAlert(message: "Failed to fetch products. Please try again.")
        }
    }


    func updateBadgeValue() {
        if let tabBarController = self.tabBarController, let items = tabBarController.tabBar.items {
            let cartItemCount = products.count
            if let cartTabBarItem = items.first(where: { $0.tag == 2 }) {
                cartTabBarItem.badgeValue = cartItemCount > 0 ? "\(cartItemCount)" : nil
                cartTabBarItem.badgeColor = UIColor(red: 0.52, green: 0.35, blue: 0.20, alpha: 1.00)
            }
        }
    }
    
    
    // MARK: Error handle
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HomeVC: MarketManagerDelegate {
    func manager(_ manager: MarketManager, didGet marketingHots: [Hots]) {
        self.marketingHots = marketingHots
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func manager(_ manager: MarketManager, didFailWith error: Error) {
        print("Network request failed: \(error)")
        showErrorAlert(message: "Failed to load marketing data. Please check your connection and try again.")
    }
}

