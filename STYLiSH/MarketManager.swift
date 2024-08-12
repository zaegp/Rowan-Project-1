import Foundation
import Kingfisher

protocol MarketManagerDelegate {
    func manager(_ manager: MarketManager, didGet marketingHots: [Hots])
    func manager(_ manager: MarketManager, didFailWith error: Error)
}

class MarketManager {
    var marketingHots = [Hots]()
    var delegate: MarketManagerDelegate?
    let baseURL = "https://api.appworks-school.tw/api/1.0"
    
    func getMarketingHots() {
        let endpoint = baseURL + "/marketing/hots"
        guard let url = URL(string: endpoint) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                print("Unable to complete your request. Please check your internet connection")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response from the server. Please try again.")
                return
            }
            
            guard let data = data else {
                print("The data received from the server was invalid. Please try again.")
                return
            }
            do {
                let decoder = JSONDecoder()
                let marketingHot = try decoder.decode(Hots.self, from: data)
                self.marketingHots.append(marketingHot)
                self.delegate?.manager(self, didGet: self.marketingHots)
            } catch {
                self.delegate?.manager(self, didFailWith: error)
            }
        }
        
        task.resume()
    }
    
}
