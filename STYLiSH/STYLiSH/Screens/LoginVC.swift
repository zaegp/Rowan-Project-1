import UIKit
import FacebookLogin

class LoginVC: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    
    private let blackView = UIView(frame: UIScreen.main.bounds)
    private let loginManager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlackView()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        blackView.isHidden = true
        
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Encountered Error: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else {
                print("Unexpected result.")
                return
            }
            
            if result.isCancelled {
                print("Login was cancelled.")
                return
            }
            
            if result.grantedPermissions.contains("email") {
                self.closeButtonTapped(self.closeButton)
                self.fetchFacebookUserInfo()
                print("Logged In")
            } else {
                print("Email permission not granted.")
            }
        }
    }
    
    private func fetchFacebookUserInfo() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id,email,name"])
        request.start { _, result, error in
            if let error = error {
                print("GraphRequest Error: \(error.localizedDescription)")
                return
            }
            
            guard result is [String: Any] else {
                print("Unexpected result.")
                return
            }
        }
    }
    
    private func setupBlackView() {
        blackView.backgroundColor = .black
        blackView.alpha = 0
        presentingViewController?.view.addSubview(blackView)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.blackView.alpha = 0.5
        }
    }
}
