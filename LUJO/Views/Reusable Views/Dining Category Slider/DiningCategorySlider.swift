//
//  DiningCategorySlider.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 9/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

protocol DidSelectCategotyItemProtocol: class {
    func didSelectSliderItemAt(indexPath: IndexPath, sender: DiningCategorySlider)
}

enum DiningCategories: String {
    case asian = "Asian"
    case french = "French"
    case pizza = "Pizza"
    case sushi = "Sushi"
    case vegan = "Vegan"
    case japanese = "Japanese"
    case italian = "Italian"
    case steakhouse = "Steakhouse"
    case bbq = "BBQ"
    case vietnamese = "Vietnamese"
    
    static let allCategories = [asian, french, pizza, sushi, vegan, japanese, italian, steakhouse, bbq, vietnamese]
    
    static func enumAsImage(type: DiningCategories) -> UIImage? {
        switch (type) {
        case .asian:
            return UIImage(named: "asian")
        case .french:
            return UIImage(named: "french")
        case .pizza:
            return UIImage(named: "pizza")
        case .sushi:
            return UIImage(named: "sushi")
        case .vegan:
            return UIImage(named: "vegan")
        case .japanese:
            return UIImage(named: "japanese")
        case .italian:
            return UIImage(named: "italian")
        case .steakhouse:
            return UIImage(named: "steakhouse")
        case .bbq:
            return UIImage(named: "bbq")
        case .vietnamese:
            return UIImage(named: "vietnamese")
        }
    }
}

class DiningCategorySlider: UIView {
    lazy var categorySliderView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: DiningCategorySliderCell.identifier, bundle: nil), forCellWithReuseIdentifier: DiningCategorySliderCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    weak var delegate: DidSelectCategotyItemProtocol?
    
    var itemsList: [Cuisine] = [] {
        didSet {
            categorySliderView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(categorySliderView)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [categorySliderView.topAnchor.constraint(equalTo: topAnchor),
             categorySliderView.bottomAnchor.constraint(equalTo: bottomAnchor),
             categorySliderView.leadingAnchor.constraint(equalTo: leadingAnchor),
             categorySliderView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension DiningCategorySlider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = categorySliderView.dequeueReusableCell(withReuseIdentifier: DiningCategorySliderCell.identifier,
                                                      for: indexPath) as! DiningCategorySliderCell
        
        let category = itemsList[indexPath.row]
        
        cell.primaryImage.downloadImageFrom(link: category.iconUrl ?? "", contentMode: .scaleAspectFill)
        cell.name.text = category.name
        
        return cell
        // swiftlint:enable force_cast
    }
}

extension DiningCategorySlider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectSliderItemAt(indexPath: indexPath, sender: self)
//        print(indexPath)
    }
}

extension DiningCategorySlider: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 72, height: 95)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
