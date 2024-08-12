import UIKit

class DetailColorCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    private var colorViews: [UIView] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func clearColorViews() {
        colorViews.forEach { $0.removeFromSuperview() }
        colorViews.removeAll()
    }
    
    func addColorChart(colors: [Color]) {
        clearColorViews()
        var previousView: UIView? = nil
        
        for color in colors {
            let newView = UIView()
            newView.layer.borderWidth = 1.0
            newView.layer.borderColor = UIColor.black.cgColor
            newView.backgroundColor = UIColor(hex: color.code)
            newView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(newView)
            
            NSLayoutConstraint.activate([
                newView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                newView.widthAnchor.constraint(equalToConstant: 24),
                newView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            if let previousView = previousView {
                NSLayoutConstraint.activate([
                    newView.leadingAnchor.constraint(equalTo: previousView.trailingAnchor, constant: 8)
                ])
            } else {
                NSLayoutConstraint.activate([
                    newView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12)
                ])
            }
            
            previousView = newView
            colorViews.append(newView)
        }
    }
}
