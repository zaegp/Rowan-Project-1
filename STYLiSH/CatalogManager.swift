import Foundation
import Alamofire

protocol CatalogManagerDelegate {
    func manager(_ manager: CatalogManager, didGet products: [Product])
    func manager(_ manager: CatalogManager, didFailWith error: Error)
}

class CatalogManager {
    let baseURL = "https://api.appworks-school.tw/api/1.0"
    var delegate: CatalogManagerDelegate?
    
    func getWomenProducts(page: Int) {
        var womenProducts = [Product]()
        let url = baseURL + "/products/women?paging=\(page)"
        
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let womenProduct = try decoder.decode(Product.self, from: data)
                    womenProducts.append(womenProduct)
                    self.delegate?.manager(self, didGet: womenProducts)
                }
                catch {
                    self.delegate?.manager(self, didFailWith: error)
                }
            case .failure(let error):
                self.delegate?.manager(self, didFailWith: error)
            }
        }
    }
    
    func getMenProducts() {
        var menProducts = [Product]()
        let url = baseURL + "/products/men"
        
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let menProduct = try decoder.decode(Product.self, from: data)
                    menProducts.append(menProduct)
                    self.delegate?.manager(self, didGet: menProducts)
                }
                catch {
                    self.delegate?.manager(self, didFailWith: error)
                }
            case .failure(let error):
                self.delegate?.manager(self, didFailWith: error)
            }
        }
    }
    
    func getaccessoriesProducts() {
        var accessoriesProducts = [Product]()
        let url = baseURL + "/products/accessories"
        
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let accessoriesProduct = try decoder.decode(Product.self, from: data)
                    accessoriesProducts.append(accessoriesProduct)
                    self.delegate?.manager(self, didGet: accessoriesProducts)
                }
                catch {
                    self.delegate?.manager(self, didFailWith: error)
                }
            case .failure(let error):
                self.delegate?.manager(self, didFailWith: error)
            }
        }
    }
}
