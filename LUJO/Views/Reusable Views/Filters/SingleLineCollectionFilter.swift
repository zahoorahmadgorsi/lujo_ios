//
//  SingleLineCollectionFilter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

protocol SingleLineCollectionFilterProtocol:class {
    func didTappedOnFilterAt(tag: Int, tappedValue: String)
}

class SingleLineCollectionFilter: UIView {

    var itemWidth:Int = 125
    var itemHeight:Int = 36
    var itemMargin:Int = 8
    var isTagLookAlike:Bool = false
    var isTextFieldHidden = true
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewTitle: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionViewParent: UIView!
    var delegate:SingleLineCollectionFilterProtocol?
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: SingleLineFilterCell.identifier, bundle: nil), forCellWithReuseIdentifier: SingleLineFilterCell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    
    var items: [filterOption] = [] {
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
        Bundle.main.loadNibNamed("SingleLineCollectionFilter", owner: self, options: nil)
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

extension SingleLineCollectionFilter : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleLineFilterCell.identifier, for: indexPath) as! SingleLineFilterCell
        
        cell.delegate = self
        let model = items[indexPath.row]
        cell.imgView.tag = indexPath.row    //to get the index when tapped on this cell
        cell.imgView.image = model.isSelected == true ? UIImage(named: "filters_check") : UIImage(named: "filters_uncheck")

        cell.lblTitle.text = model.name

        //change cell looks like a tag, default value is false
        cell.changeCellLook(isTagLookAlike: isTagLookAlike, isSelected: model.isSelected ?? false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (isTagLookAlike){
            for i in 0..<self.items.count{
//                if (i == indexPath.row){
//                    if let isSelected = self.items[i].isSelected{
//                        self.items[i].isSelected = !isSelected
//                    }
//                }else{
//                    items[i].isSelected = false
//                }
            }
            self.collectionView.reloadData()
        }
    }

}

extension SingleLineCollectionFilter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: CGFloat(itemMargin), bottom: 0, right: CGFloat(itemMargin)) 
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

extension SingleLineCollectionFilter:SingleLineFilterCellProtocol{

    
    func didTappedOnItem(at index: Int) {
        for i in 0..<self.items.count{
            if (i == index){    //only interested in tapped item
                let isSelected = self.items[i].isSelected ?? false
                if let value = self.items[i].value{
                    self.items[i].isSelected = !isSelected
                    delegate?.didTappedOnFilterAt(tag: self.tag, tappedValue: value)
                }
            }
            else if self.tag == FilterType.YachtStatus.rawValue ||
                    self.tag == FilterType.YachtCharter.rawValue ||
                    self.tag == FilterType.YachtType.rawValue 
            {//disable multiSelection
                self.items[i].isSelected = false //uncomment if you want to disable multi selection
            }
        }
        self.collectionView.reloadData()    //reload collection after updating the model
    }
}
