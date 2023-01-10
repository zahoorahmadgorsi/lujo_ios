//
//  SingleLineCollectionFilter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

protocol YachtLengthFilterProtocol:class {
    func didTappedOnCheckBox(index:Int)
}

class YachtLengthFilter: UIView {

    var itemWidth:Int = 150
    var itemHeight:Int = 48
    var itemMargin:Int = 8
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblFeet: UILabel!
    @IBOutlet weak var collFeet: UICollectionView!
    @IBOutlet weak var lblMeter: UILabel!
    @IBOutlet weak var collMeter: UICollectionView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionViewFeetParent: UIView!
    @IBOutlet weak var collectionViewMetersParent: UIView!
    var delegate:YachtLengthFilter?
    var tagOffset = 50
        
    lazy var collectionViewFeet: UICollectionView = {
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
    
    lazy var collectionViewMeters: UICollectionView = {
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
    
    var feet: [Taxonomy] = [] {
        didSet {
            collectionViewFeet.reloadData()
        }
    }
    
    var meters: [Taxonomy] = [] {
        didSet {
            collectionViewMeters.reloadData()
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
        Bundle.main.loadNibNamed("YachtLengthFilter", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        collectionViewFeetParent.addSubview(collectionViewFeet)
        collectionViewMetersParent.addSubview(collectionViewMeters)
        setupLayout()
        
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [collectionViewFeet.topAnchor.constraint(equalTo: collectionViewFeetParent.topAnchor),
             collectionViewFeet.bottomAnchor.constraint(equalTo: collectionViewFeetParent.bottomAnchor),
             collectionViewFeet.leadingAnchor.constraint(equalTo: collectionViewFeetParent.leadingAnchor),
             collectionViewFeet.trailingAnchor.constraint(equalTo: collectionViewFeetParent.trailingAnchor)]
        )
        
        NSLayoutConstraint.activate(
            [collectionViewMeters.topAnchor.constraint(equalTo: collectionViewMetersParent.topAnchor),
             collectionViewMeters.bottomAnchor.constraint(equalTo: collectionViewMetersParent.bottomAnchor),
             collectionViewMeters.leadingAnchor.constraint(equalTo: collectionViewMetersParent.leadingAnchor),
             collectionViewMeters.trailingAnchor.constraint(equalTo: collectionViewMetersParent.trailingAnchor)]
        )
    }

}

extension YachtLengthFilter : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == collectionViewFeet){
            return feet.count
        }else if (collectionView == collectionViewMeters){
            return meters.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleLineFilterCell.identifier,
                                                      for: indexPath) as! SingleLineFilterCell
        cell.delegate = self
        var model = feet[indexPath.row]
        if (collectionView == collectionViewMeters){    //incase current collection view is meters
            model = meters[indexPath.row]
        }
        //if collection view is feet then tag would be 1,2,3 else if its meters then tag would be 51, 52, 53
        cell.imgView.tag = (collectionView == collectionViewFeet ? 0 : tagOffset ) + indexPath.row    //to get the index when tapped on this cell
//        print("IsSelected: \(model.isSelected)")
        cell.imgView.image = model.isSelected == true ? UIImage(named: "filters_check") : UIImage(named: "filters_uncheck")
        
        cell.lblTitle.text = model.name
        return cell
    }
    

}

extension YachtLengthFilter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(itemMargin), bottom: 0, right: CGFloat(itemMargin))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(itemMargin)
    }
}

extension YachtLengthFilter:SingleLineFilterCellProtocol{
    func didTappedOnItem(at index: Int) {
        print(index)
        if index / tagOffset == 0 { //tapp is on feet
            for i in 0..<self.feet.count{
                if (i == index){
                    if let isSelected = self.feet[i].isSelected{
                        self.feet[i].isSelected = !isSelected
                    }
                    
                }else{
                    self.feet[i].isSelected = false
                }
            }
            for i in 0..<self.meters.count{ //incase of feet set all meters to false
                self.meters[i].isSelected = false
            }
            
        }else{  //tap is on meters
            for i in 0..<self.meters.count{
                if (i + tagOffset == index){
                    if let isSelected = self.meters[i].isSelected{
                        self.meters[i].isSelected = !isSelected
                    }
                }else{
                    self.meters[i].isSelected = false
                }
            }
            for i in 0..<self.feet.count{ //incase of meters set all feet to false
                self.feet[i].isSelected = false
            }
        }
        self.collectionViewFeet.reloadData()
        self.collectionViewMeters.reloadData()
          //reload collection after updating the model
    }
    
    func didTappedOnCheckBox(index: Int) {
//        print("index / tagOffset:\(index / tagOffset)")
       
    }
}
