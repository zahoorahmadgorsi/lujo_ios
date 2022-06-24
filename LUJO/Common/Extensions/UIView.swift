import UIKit

extension UIView {
    enum ViewSide {
        case leftMargin, rightMargin, topMargin, bottomMargin
    }

    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color

        switch side {
        case .leftMargin:
            border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height)
        case .rightMargin:
            border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height)
        case .topMargin:
            border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness)
        case .bottomMargin:
            border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness)
        }

        layer.addSublayer(border)
    }

    public func addViewBorder(borderColor:CGColor,borderWidth:CGFloat, borderCornerRadius:CGFloat){
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor
            self.layer.cornerRadius = borderCornerRadius

        }
    
    func currentFirstResponder() -> UIResponder? {
        if isFirstResponder {
            return self
        }

        for view in subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }

        return nil
    }

    func addAndFillSubview(_ view: UIView) {
        view.removeFromSuperview()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                         toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal,
                                         toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                         toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                         toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }

    func removeLayer(layerName: String) {
        for item in self.layer.sublayers ?? [] where item.name == layerName {
                item.removeFromSuperlayer()
        }
    }
    
    func addSubview(_ view: UIView, to side: ViewSide, with length: CGFloat) {
        view.removeFromSuperview()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        if side != .rightMargin {
            addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                             toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        }
        if side != .leftMargin {
            addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal,
                                             toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        }
        if side != .bottomMargin {
            addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                             toItem: self, attribute: .top, multiplier: 1, constant: 0))
        }
        if side != .topMargin {
            addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                             toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        }

        switch side {
        case .leftMargin, .rightMargin:
            addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal,
                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: length))
        case .topMargin, .bottomMargin:
            addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal,
                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: length))
        }
    }

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    static func instantiateFromNib<T: UIView>() -> T? {
        return UINib(nibName: "\(self)", bundle: nil).instantiate(withOwner: nil, options: nil).first as? T
    }
    
    static func createVerticalSeparator(size: CGSize) -> UIView {
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let verticalBar = UIView()
        verticalBar.translatesAutoresizingMaskIntoConstraints = false
        verticalBar.backgroundColor = UIColor.rgMid
        separator.addSubview(verticalBar)
        NSLayoutConstraint.activate([
            verticalBar.heightAnchor.constraint(equalToConstant: size.height),
            verticalBar.widthAnchor.constraint(equalToConstant: 1),
            verticalBar.centerXAnchor.constraint(equalTo: separator.centerXAnchor),
            verticalBar.centerYAnchor.constraint(equalTo: separator.centerYAnchor),
        ])

        return separator
    }

    static func createHorizSeparator(size: CGSize, margin: CGFloat, background: UIColor) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.backgroundColor = background
        let horizontalBar = UIView()
        horizontalBar.translatesAutoresizingMaskIntoConstraints = false
        horizontalBar.backgroundColor = UIColor.inputBorderNoFocus
        view.addSubview(horizontalBar)
        NSLayoutConstraint.activate([
            horizontalBar.heightAnchor.constraint(equalToConstant: 1),
            horizontalBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            horizontalBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            horizontalBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }

    func fixInView(_ container: UIView!) {
        translatesAutoresizingMaskIntoConstraints = false
        frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
    
    func addBackGroundImage(imageName:String){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: imageName)
        backgroundImage.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.insertSubview(backgroundImage, at: 0)
    }
}

