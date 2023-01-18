//
//  SingleLineCollectionFilter.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit
import AVFoundation

enum FilterCellType:String{
    case SortBy, FilterBy
}

protocol GiftFilterProtocol{
    var identifier: String { get set }
    var delegate:TapOnGiftCellProtocol? { get set }
    
    func reset()
    func setTitle(title:String)
    func setLeftRightImages(leftImageName: String, rightImageName: String)
}

class GiftsCollectionFilter: UIView {

    var itemWidth:Int = 125
    var itemHeight:Int = 36
    var itemMargin:Int = 8
    var isTagLookAlike:Bool = false
    
    
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var collectionViewParent: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var fullViewHeight: NSLayoutConstraint!
    
    
    
    var delegate:SingleLineCollectionFilterProtocol?
    var cell: GiftFilterProtocol!
    //used in gift filter
    var leftImageName:String = ""
    var rightImageName:String = ""
    var filterCellType:FilterCellType?
    
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: cell.identifier, bundle: nil), forCellWithReuseIdentifier: cell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    public init(cell: GiftFilterProtocol, cellWidth: Int, cellHeight: Int, leftImageName:String = "", rightImageName:String = "", filterCellType: FilterCellType? = nil){
        self.cell = cell
        self.itemWidth = cellWidth
        self.itemHeight = cellHeight
        self.leftImageName = leftImageName
        self.rightImageName = rightImageName
        self.filterCellType = filterCellType
        super.init(frame: .zero)
        commonInit()
    }
    
    //when user will pick some thing from the picker then that picked item is going to show hence need to increase control height and in case of vertical orientation it contains items which are displayed for user to pick one of these i.e incase of gifts filter sort by and filter by
    var pickedItems: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
            var _pickedItemsViewHeight = 0.0
                _pickedItemsViewHeight = pickedItems.count > 0 ? Double((pickedItems.count * (self.itemHeight + self.itemMargin) )) : 0.0

//            //setting the view height to dynamic
            self.fullViewHeight.constant =  self.titleView.frame.height  + _pickedItemsViewHeight
//            print("title Height: \(self.titleView.frame.height)", "text Field Height: \(_textFieldHeight)")
//            print("picked Items View Height: \(_pickedItemsViewHeight)","view full Height: \(self.fullViewHeight.constant)"  )
            self.collectionView.layoutIfNeeded()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GiftsCollectionFilter", owner: self, options: nil)
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
    
    func getStringArrayFromTaxonomyArray(taxonomies : [Taxonomy])->[[String]]{
        var _stringArray:[[String]] = [[]]
        if taxonomies.count > 0{
            for category in taxonomies{
                _stringArray[0].append(category.name)
            }
        }
        return _stringArray
    }
    
}

extension GiftsCollectionFilter : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as? GiftFilterProtocol{
            cell.delegate = self
            if let giftCell = cell as? GiftFilterCell{
                giftCell.mainView.tag = indexPath.row
                giftCell.filterCellType = self.filterCellType
            }
            let model = pickedItems[indexPath.row]
            
            cell.setTitle(title: model.name)
            
            if model.isSelected == true && self.filterCellType == FilterCellType.SortBy{
                cell.setLeftRightImages(leftImageName: self.leftImageName, rightImageName: "filters_check")
            }else{
                cell.setLeftRightImages(leftImageName: self.leftImageName, rightImageName: self.rightImageName)
            }

            return cell as! UICollectionViewCell
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //when tapped on the cell it should be removed in case of tags, event category, villa lifestyle etc
        self.collectionView.deleteItems(at: [indexPath])
        self.pickedItems.remove(at: indexPath.row)
    }
}

extension GiftsCollectionFilter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(itemMargin)
//        return 0
    }
}

extension GiftsCollectionFilter: TapOnGiftCellProtocol{

    
    func didTappedOnItem(at index: Int, filterCellType: FilterCellType?) {
        print("index: \(index)" , "filterCellType: \(String(describing: filterCellType))")
        if filterCellType == FilterCellType.SortBy{
            for i in 0..<(self.pickedItems.count ){
                if (i == index){    //only interested in tapped item
                    self.pickedItems[i].isSelected = !(self.pickedItems[index].isSelected ?? false)
                        //delegate?.didTappedOnFilterAt(tag: self.tag, tappedValue: value)
                }
                else{//disable multiSelection
                    self.pickedItems[i].isSelected = false //uncomment if you want to disable multi selection
                }
            }
            self.collectionView.reloadData()    //reload collection after updating the model
        }
    }
}

