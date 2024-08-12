import UIKit
import IQKeyboardManagerSwift

protocol AddToCartCellDelegate: AnyObject {
    func didRequestData(cell: AddToCartCell, data: [String])
}

class AddToCartCell: UITableViewCell, UITextFieldDelegate {
    weak var delegate: AddToCartCellDelegate?
    private var colorButtons: [UIButton] = []
    private var colorViews: [UIView] = []
    private var colorCodeString: [String] = []
    private var colorNameString: [String] = []
    private var selectedColor = ""
    private var sizeButtons: [UIButton] = []
    private var sizeViews: [UIView] = []
    private var sizeString: [String] = []
    private var selectedSize = ""
    private var stock = 0
    private var count = 1
    var cartProduct: [String] = ["", "", "1", "", ""]
    var variants: [Variant] = []
    var enableCartButton: (() -> Void)?
    var disableCartButton: (() -> Void)?
    
    func passData() -> [String] {
        return cartProduct
    }
    
    func setVariants(variants: [Variant]) {
        self.variants = variants
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        self.selectionStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        self.selectionStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func setupViews() {
        contentView.addSubview(colorlabel)
        contentView.addSubview(sizelabel)
        contentView.addSubview(numberlabel)
        contentView.addSubview(shortageOfStockLabel)
        setupLabelConstraints()
        shortageOfStockLabel.isHidden = true
        leftButton.isEnabled = false
        textField.isEnabled = false
        rightButton.isEnabled = false
        leftButton.alpha = 0.5
        textField.alpha = 0.5
        rightButton.alpha = 0.5
    }
    
    // MARK: Label
    private let colorlabel: UILabel = {
        let colorlabel = UILabel()
        colorlabel.text = "選擇顏色"
        colorlabel.font = UIFont.systemFont(ofSize: 14)
        colorlabel.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        colorlabel.translatesAutoresizingMaskIntoConstraints = false
        return colorlabel
    }()
    
    private let sizelabel: UILabel = {
        let sizelabel = UILabel()
        sizelabel.text = "選擇尺寸"
        sizelabel.font = UIFont.systemFont(ofSize: 14)
        sizelabel.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        sizelabel.translatesAutoresizingMaskIntoConstraints = false
        return sizelabel
    }()
    
    private let numberlabel: UILabel = {
        let numberlabel = UILabel()
        numberlabel.text = "選擇數量"
        numberlabel.font = UIFont.systemFont(ofSize: 14)
        numberlabel.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        numberlabel.translatesAutoresizingMaskIntoConstraints = false
        return numberlabel
    }()
    
    private let stockLabel: UILabel = {
        let stockLabel = UILabel()
        stockLabel.font = UIFont.systemFont(ofSize: 14)
        stockLabel.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        return stockLabel
    }()
    
    private let shortageOfStockLabel: UILabel = {
        let shortageOfStockLabel = UILabel()
        shortageOfStockLabel.text = "庫存不足"
        shortageOfStockLabel.font = UIFont.systemFont(ofSize: 14)
        shortageOfStockLabel.textColor = .red
        shortageOfStockLabel.translatesAutoresizingMaskIntoConstraints = false
        return shortageOfStockLabel
    }()
    
    private func setupLabelConstraints() {
        NSLayoutConstraint.activate([
            colorlabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorlabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            sizelabel.topAnchor.constraint(equalTo: colorlabel.bottomAnchor, constant: 80),
            sizelabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberlabel.topAnchor.constraint(equalTo: sizelabel.bottomAnchor, constant: 80),
            numberlabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            shortageOfStockLabel.topAnchor.constraint(equalTo: numberlabel.bottomAnchor, constant: 63),
            shortageOfStockLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    
    // MARK: Color
    private func clearColorButtons() {
        colorButtons.forEach { $0.removeFromSuperview() }
        colorViews.forEach { $0.removeFromSuperview() }
        colorButtons.removeAll()
        colorViews.removeAll()
    }
    
    func addColorChart(colors: [Color]) {
        clearColorButtons()
        var previousButton: UIButton? = nil
        
        for (index, color) in colors.enumerated() {
            let viewBelowButton = UIView()
            viewBelowButton.translatesAutoresizingMaskIntoConstraints = false
            viewBelowButton.backgroundColor = UIColor.white
            viewBelowButton.layer.borderColor = UIColor.black.cgColor
            viewBelowButton.layer.borderWidth = 1
            contentView.addSubview(viewBelowButton)
            colorViews.append(viewBelowButton)
            
            let button = UIButton()
            button.backgroundColor = UIColor(hex: color.code)
            colorCodeString.append(color.code)
            colorNameString.append(color.name)
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            
            contentView.addSubview(button)
            colorButtons.append(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 48),
                button.heightAnchor.constraint(equalToConstant: 48),
            ])
            
            NSLayoutConstraint.activate([
                viewBelowButton.widthAnchor.constraint(equalToConstant: 48),
                viewBelowButton.heightAnchor.constraint(equalToConstant: 48),
            ])
            
            if let previousButton = previousButton {
                NSLayoutConstraint.activate([
                    viewBelowButton.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 8),
                    viewBelowButton.topAnchor.constraint(equalTo: colorlabel.bottomAnchor, constant: 12),
                    button.centerYAnchor.constraint(equalTo: viewBelowButton.centerYAnchor),
                    button.centerXAnchor.constraint(equalTo: viewBelowButton.centerXAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    viewBelowButton.topAnchor.constraint(equalTo: colorlabel.bottomAnchor, constant: 12),
                    viewBelowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    button.centerYAnchor.constraint(equalTo: viewBelowButton.centerYAnchor),
                    button.centerXAnchor.constraint(equalTo: viewBelowButton.centerXAnchor)
                ])
            }
            
            previousButton = button
            colorButtons.append(button)
        }
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        let buttonIndex = sender.tag
        enableCartButton?()
        if selectedSize == "" {
            disableCartButton!()
        }
        count = 1
        selectedColor = colorCodeString[buttonIndex]
        cartProduct[0] = selectedColor
        cartProduct[4] = colorNameString[buttonIndex]
        calculateStock()
        stockLabel.text = "庫存：" + String(stock)
        cartProduct[3] = String(stock)
        textField.text = String(count)
        leftButton.isEnabled = false
        inStock()
        for button in sizeButtons {
            button.isEnabled = true
            button.alpha = 1
        }
        
        for view in sizeViews {
            view.isHidden = false
        }
        
        for i in 0..<sizeButtons.count {
            if let outOfStockIndex = outOfStockSize(), i == outOfStockIndex {
                sizeButtons[i].isEnabled = false
                sizeButtons[i].alpha = 0.5
                sizeViews[i].isHidden = true
            }
        }
        
        for button in colorButtons {
            button.isSelected = false
            if button == sender {
                button.isSelected.toggle()
                if button.isSelected {
                    button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                } else {
                    button.transform = CGAffineTransform.identity
                }
            } else {
                button.isSelected = false
                button.transform = CGAffineTransform.identity
            }
        }
    }
    
    
    // MARK: Size
    private func clearSizeButtons() {
        sizeButtons.forEach { $0.removeFromSuperview() }
        sizeViews.forEach { $0.removeFromSuperview() }
        sizeButtons.removeAll()
        sizeViews.removeAll()
    }
    
    func addSizeChart(sizes: [String]) {
        clearSizeButtons()
        var previousButton: UIButton? = nil
        
        for (index, size) in sizes.enumerated() {
            let viewBelowButton = UIView()
            viewBelowButton.translatesAutoresizingMaskIntoConstraints = false
            viewBelowButton.backgroundColor = UIColor.white // 设置背景色或其他属性
            viewBelowButton.layer.borderColor = UIColor.black.cgColor
            viewBelowButton.layer.borderWidth = 1
            viewBelowButton.isHidden = true
            contentView.addSubview(viewBelowButton)
            sizeViews.append(viewBelowButton)
            
            let button = UIButton()
            button.isEnabled = false
            button.alpha = 0.5
            button.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00)
            button.setTitle(size, for: .normal)
            sizeString.append(size)
            button.setTitleColor(.black, for: .normal)
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
            
            contentView.addSubview(button)
            sizeButtons.append(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 48),
                button.heightAnchor.constraint(equalToConstant: 48),
                viewBelowButton.widthAnchor.constraint(equalToConstant: 48),
                viewBelowButton.heightAnchor.constraint(equalToConstant: 48)
            ])
            
            if let previousButton = previousButton {
                NSLayoutConstraint.activate([
                    viewBelowButton.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 8),
                    viewBelowButton.topAnchor.constraint(equalTo: sizelabel.bottomAnchor, constant: 12),
                    button.centerYAnchor.constraint(equalTo: viewBelowButton.centerYAnchor),
                    button.centerXAnchor.constraint(equalTo: viewBelowButton.centerXAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    viewBelowButton.topAnchor.constraint(equalTo: sizelabel.bottomAnchor, constant: 12),
                    viewBelowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    button.centerYAnchor.constraint(equalTo: viewBelowButton.centerYAnchor),
                    button.centerXAnchor.constraint(equalTo: viewBelowButton.centerXAnchor)
                ])
            }
            
            previousButton = button
            sizeButtons.append(button)
        }
    }
    
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        enableCartButton?()
        let buttonIndex = sender.tag
        selectedSize = sizeString[buttonIndex]
        cartProduct[1] = selectedSize
        textField.isEnabled = true
        leftButton.isEnabled = false
        count = 1
        calculateStock()
        if stock > 1 {
            rightButton.isEnabled = true
        }
        textField.text = String(count)
        textField.alpha = 1
        rightButton.alpha = 1
        inStock()
        
        
        stockLabel.text = "庫存：" + String(stock)
        cartProduct[3] = String(stock)
        contentView.addSubview(stockLabel)
        NSLayoutConstraint.activate([
            stockLabel.centerYAnchor.constraint(equalTo: numberlabel.centerYAnchor),
            stockLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        for button in sizeButtons {
            button.isSelected = false
            if button == sender {
                button.isSelected.toggle()
                if button.isSelected {
                    button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                } else {
                    button.transform = CGAffineTransform.identity
                }
            } else {
                button.isSelected = false
                button.transform = CGAffineTransform.identity
            }
        }
    }
    
    
    // MARK: Textfield
    private let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Icons_24px_Subtract01"), for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(AddToCartCell.self, action: #selector(subtractButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func subtractButtonTapped(_ sender: UIButton) {
        if count <= stock + 1 {
            inStock()
        }
        count -= 1
        textField.text = String(count)
        cartProduct[2] = textField.text!
        if count <= 1 {
            leftButton.isEnabled = false
            leftButton.alpha = 0.5
        } else {
            leftButton.isEnabled = true
            leftButton.alpha = 1
        }
        if count >= stock {
            rightButton.isEnabled = false
            rightButton.alpha = 0.5
        } else {
            rightButton.isEnabled = true
            rightButton.alpha = 1
        }
    }
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 0
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.clearButtonMode = .never
        
        return textField
    }()
    
    @objc func textDidChange(_ notification: Notification) {
        if let textField = notification.object as? UITextField {
            cartProduct[2] = textField.text ?? ""
            if textField.text!.count == 0 {
                inStock()
                disableCartButton?()
                rightButton.isEnabled = true
                rightButton.alpha = 1
            }
            
            if textField.text!.count == 1 {
                inStock()
                enableCartButton?()
                rightButton.isEnabled = true
                rightButton.alpha = 1
            }
            
            let text = textField.text ?? ""
            let value = Int(text)
            if value ?? 1 <= 1 {
                leftButton.isEnabled = false
                leftButton.alpha = 0.5
            }
            if value == 0 {
                disableCartButton?()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? "1"
        
        if string.isEmpty {
            count = 0
            return true
        }
        
        let newString = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        guard let number = Int(newString) else {
            return false
        }
        enableCartButton?()
        if number > stock {
            count = stock
            shortageOfStock()
            textField.text = String(count)
            rightButton.isEnabled = false
            rightButton.alpha = 0.5
            if stock >= 1{
                leftButton.isEnabled = true
                leftButton.alpha = 1
            }
            return number <= stock
        } else {
            count = number
            inStock()
            return number <= stock
        }
    }
    
    func setupTextField() {
        let stackView = UIStackView(arrangedSubviews: [leftButton, textField, rightButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: numberlabel.bottomAnchor, constant: 8),
            stackView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        leftButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Icons_24px_Add01"), for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(AddToCartCell.self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        count += 1
        enableCartButton?()
        textField.text = String(count)
        inStock()
        cartProduct[2] = textField.text!
        if count <= 1 {
            leftButton.isEnabled = false
            leftButton.alpha = 0.5
        } else {
            leftButton.isEnabled = true
            leftButton.alpha = 1
        }
        if count >= stock {
            rightButton.isEnabled = false
            rightButton.alpha = 0.5
        } else {
            rightButton.isEnabled = true
            rightButton.alpha = 1
        }
    }
    
    private func calculateStock() {
        stock = 0
        for variant in variants {
            if selectedColor == variant.color_code && selectedSize == variant.size {
                stock += variant.stock
            }
        }
    }
    
    private func outOfStockSize() -> Int? {
        for variant in variants {
            if selectedColor == variant.color_code && variant.stock == 0 {
                for (index, string) in sizeString.enumerated() {
                    if string == variant.size {
                        return index
                    }
                }
            }
        }
        return nil
    }
    
    private func shortageOfStock() {
        numberlabel.textColor = .red
        stockLabel.textColor = .red
        textField.textColor = .red
        shortageOfStockLabel.isHidden = false
    }
    
    private func inStock() {
        numberlabel.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        stockLabel.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        textField.textColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1.00)
        shortageOfStockLabel.isHidden = true
    }
    
    @objc private func addToCartButton() {
            enableCartButton?()
        }
}
