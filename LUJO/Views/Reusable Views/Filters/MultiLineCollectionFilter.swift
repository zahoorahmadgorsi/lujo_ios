//
//  SingleLineCollectionFilter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

class MultiLineCollectionFilter: UIView {

    var itemWidth:Int = 125
    var itemHeight:Int = 36
    var itemMargin:Int = 8
    var isTagLookAlike:Bool = false
    var isTextFieldHidden = true
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewTitle: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var collectionViewParent: UIView!
    var delegate:SingleLineCollectionFilterProtocol?
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: AirportCollViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: AirportCollViewCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    
    var items: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MultiLineCollectionFilter", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        collectionViewParent.addSubview(collectionView)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [collectionView.topAnchor.constraint(equalTo: collectionViewParent.topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: collectionViewParent.bottomAnchor),
             collectionView.leadingAnchor.constraint(equalTo: collectionViewParent.leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: collectionViewParent.trailingAnchor)]
        )
    }
}

extension MultiLineCollectionFilter : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AirportCollViewCell.identifier, for: indexPath) as! AirportCollViewCell
        
        let model = items[indexPath.row]
        cell.lblTitle.text = model.name

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (isTagLookAlike){
            for i in 0..<self.items.count{
                if (i == indexPath.row){
                    if let isSelected = self.items[i].isSelected{
                        self.items[i].isSelected = !isSelected
                    }
                }else{
                    items[i].isSelected = false
                }
            }
            self.collectionView.reloadData()
        }
    }

}

extension MultiLineCollectionFilter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: CGFloat(0), bottom: 0, right: CGFloat(0))
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(itemMargin)
    }
}

