import UIKit
import Alamofire
import KeychainAccess

protocol CheckoutManagerDelegate: AnyObject {
    func didProvideOrderData(parameters: [String: Any])
}

class CheckoutManager {
    weak var delegate: CheckoutManagerDelegate?
    var parameters: [String: Any]?
    let keychain = Keychain(service: "com.raywenderlich.STYLiSH")
    
    func postOrder() {
        guard let parameters = parameters else { return }
                if !JSONSerialization.isValidJSONObject(parameters) {
                    print("Error: The parameters dictionary is not a valid JSON object.")
                    return
                }
        
        let url = "https://api.appworks-school.tw/api/1.0/order/checkout"
        do {
            guard let token = try keychain.get("STYLiSHToken") else {
                print("No access token found")
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("Success: \(value)")
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
        } catch {
            print("Failed to retrieve token from Keychain: \(error)")
        }
    }
}
