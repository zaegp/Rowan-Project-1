import UIKit

class AddToCartHeader: UIView {
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let separatorView = UIView()
    let closeButton = UIButton()
        
    var onCloseButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView(title: String, price: Int) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = .black
        addSubview(titleLabel)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = "NT$ " + String(price)
        priceLabel.font = UIFont.systemFont(ofSize: 18)
        priceLabel.textColor = .black
        addSubview(priceLabel)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        addSubview(closeButton)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.gray
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            priceLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 57),
            priceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    @objc private func closeButtonTapped() {
            onCloseButtonTapped?()
        }
    
}
