import UIKit
import Alamofire
import KeychainAccess
import FacebookLogin

protocol FacebookManagerDelegate: AnyObject {
    func didReceiveUserInfo(name: String, picture: String)
}

class FacebookManager {
    
    weak var delegate: FacebookManagerDelegate?
    var refreshToken: String?
    let keychain = Keychain(service: "com.raywenderlich.STYLiSH")
    private let postUrl = "https://api.appworks-school.tw/api/1.0/user/signin"
    private let getUrl = "https://api.appworks-school.tw/api/1.0/user/profile"
    private var parameters: [String: Any] = [
        "provider":"facebook",
        "access_token": AccessToken.current?.tokenString ?? ""
    ]
    
    func postFacebook() {
        AF.request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any],
                       let data = json["data"] as? [String: Any],
                       let accessToken = data["access_token"] as? String {
                        do {
                            try keychain.set(accessToken, key: "STYLiSHToken")
                            getUserProfile()
                        } catch {
                            print("Failed to save accessToken to Keychain: \(error)")
                        }
                    } else {
                        print("Unexpected JSON structure")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    func getUserProfile() {
        do {
            guard let token = try keychain.get("STYLiSHToken") else {
                print("No access token found")
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            
            AF.request(getUrl, method: .get, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print(value)
                        if let json = value as? [String: Any],
                           let data = json["data"] as? [String: Any] {
                            let name = data["name"] as? String
                            let picture = data["picture"] as? String
                            
                            if let name = name, let picture = picture {
                                self.delegate?.didReceiveUserInfo(name: name, picture: picture)
                            }
                        } else {
                            print("Unexpected JSON structure")
                        }
                        
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
        } catch {
            print("Failed to retrieve accessToken from Keychain: \(error)")
        }
    }
}

