import UIKit
import FacebookLogin

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var disabledItemIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func isUserLoggedIn() -> Bool {
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            return true
        } else {
            return false
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 3 {
            if !isUserLoggedIn() {
                performSegue(withIdentifier: "showLogin", sender: self)
                return false
            } else {
                let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"])
                request.start { response, result, error in
                    if let result = result as? [String:String] {
                        print(result)
                    }
                }
            }
        }
        if let viewControllers = tabBarController.viewControllers,
           let index = viewControllers.firstIndex(of: viewController) {
            if index == disabledItemIndex {
                return false
            }
        }
        return true
    }
    
    func disableTabBarItem(at index: Int) {
        disabledItemIndex = index
    }
    
    func enableTabBarItem(at index: Int) {
        if disabledItemIndex == index {
            disabledItemIndex = nil
        }
    }
}

