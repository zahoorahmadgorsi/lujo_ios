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
    
    
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var collectionViewParent: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var fullViewHeight: NSLayoutConstraint!
    
    
    
    var delegate:SingleLineCollectionFilterProtocol?
    var cell: MultiLineFilterProtocol!
    var scrollDirection: UICollectionView.ScrollDirection!
    //used in gift filter
    var leftImageName:String = ""
    var rightImageName:String = ""
    
    var picker: ikDataPickerManger?
    var strPickerSelection:String?  //what user has picked from the picker would be saved here
    var items:[Taxonomy]?   //it contains taxonomy data whose name keys are loaded into picker
    var pickerItems: [[String]] = [[]] {
        didSet {
//            collectionView.reloadData()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = self.scrollDirection
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: cell.identifier, bundle: nil), forCellWithReuseIdentifier: cell.identifier)
        contentView.backgroundColor = .clear
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    public init(cell: MultiLineFilterProtocol, cellWidth: Int, cellHeight: Int, scrollDirection: UICollectionView.ScrollDirection, leftImageName:String = "", rightImageName:String = ""){
        self.cell = cell
        self.itemWidth = cellWidth
        self.itemHeight = cellHeight
        self.scrollDirection = scrollDirection
        self.leftImageName = leftImageName
        self.rightImageName = rightImageName
        super.init(frame: .zero)
        commonInit()
    }
    
    var pickedItems: [Taxonomy] = [] {
        didSet {
            collectionView.reloadData()
            print(self.collectionViewParent.frame.height , (pickedItems.count > 0 ? 1 : 0))
            var collectionViewParentHeight = CGFloat(48) * (pickedItems.count > 0 ? 1 : 0) //48 is the height of collectionViewParent
//            //setting the view height to dynamic
            print(self.titleView.frame.height,self.txtName.frame.height)
            self.fullViewHeight.constant =  self.titleView.frame.height + self.txtName.frame.height + collectionViewParentHeight  + 16
            self.collectionView.layoutIfNeeded()
        }
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }

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
        txtName.delegate = self
        
    }
    
    override func didMoveToSuperview(){
        super.didMoveToSuperview()
        if self.tag == FilterType.EventCategory.rawValue{   //event category
            GoLujoAPIManager().getEventCategory() { taxonomies, error in
                guard error == nil else {
                    return
                }
                self.items = taxonomies
                self.pickerItems = self.getStringArrayFromTaxonomyArray(taxonomies: taxonomies ?? [])
            }
        }else if self.tag == FilterType.EventTags.rawValue{   //event tags
            GoLujoAPIManager().getEventTags() { taxonomies, error in
                guard error == nil else {
                    return
                }
                self.items = taxonomies
                self.pickerItems = self.getStringArrayFromTaxonomyArray(taxonomies: taxonomies ?? [])
            }
        }else if self.tag == FilterType.ExperienceCategory.rawValue{   //event category
            GoLujoAPIManager().getExperienceCategory() { taxonomies, error in
                guard error == nil else {
                    return
                }
                self.items = taxonomies
                self.pickerItems = self.getStringArrayFromTaxonomyArray(taxonomies: taxonomies ?? [])
            }
        }else if self.tag == FilterType.ExperienceTags.rawValue{   //event tags
            GoLujoAPIManager().getExperienceTags() { taxonomies, error in
                guard error == nil else {
                    return
                }
                self.items = taxonomies
                self.pickerItems = self.getStringArrayFromTaxonomyArray(taxonomies: taxonomies ?? [])
            }
        }else if self.tag == FilterType.VillaType.rawValue || self.tag == FilterType.VillaLifeStyle.rawValue{   //villa types, life styles
            self.pickerItems = self.getStringArrayFromTaxonomyArray(taxonomies: self.items ?? [])
        }
            
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

extension MultiLineCollectionFilter : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as? MultiLineFilterProtocol{
            
            let model = pickedItems[indexPath.row]
            
            cell.setTitle(title: model.name)
            cell.setLeftRightImages(leftImageName: self.leftImageName, rightImageName: self.rightImageName)   

            return cell as! UICollectionViewCell
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if (isTagLookAlike){
//            for i in 0..<self.items.count{
//                if (i == indexPath.row){
//                    if let isSelected = self.items[i].isSelected{
//                        self.items[i].isSelected = !isSelected
//                    }
//                }else{
//                    items[i].isSelected = false
//                }
//            }
//            self.collectionView.reloadData()
//        }
        //when tapped on the cell it should be removed
        self.collectionView.deleteItems(at: [indexPath])
        self.pickedItems.remove(at: indexPath.row)
    }

    func loadPickerItems(textField: UITextField){
        self.parentViewController?.view.endEditing(true)
        
        if picker == nil {
            self.picker = ikDataPickerManger.create(owner: self.parentViewController!, sourceView: textField , title: "Please select one", dataSource: self.pickerItems, callback: { values in
                if values.count > 0{
                    let _pickedString = values[0]
                    self.strPickerSelection = _pickedString
                    
                    if let _pickedItem = self.items?.filter({$0.name == _pickedString}){
                        var _temp = self.pickedItems
                        _temp.append(contentsOf: _pickedItem)
                        self.pickedItems = _temp  //it will reload
                    }
                    
                    
                }
            })
            
        }
        picker?.present()
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
//        return 0
    }
}

extension MultiLineCollectionFilter:  UITextFieldDelegate{
    //making preffered destination field uneditable
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print (self.tag)
        //if textField == self.txtName {
//        if self.tag == FilterType.EventLocation.rawValue{   //event region
//            let viewController = DestinationSelectionViewController.instantiate(prefInformationType: .yachtPreferredRegions)   //pass regions
////                viewController.delegate = self
//            self.parentViewController?.present(viewController, animated: true, completion: nil)
//            return false
//        }
        if self.tag == FilterType.EventCategory.rawValue ||
            self.tag == FilterType.EventTags.rawValue ||
            self.tag == FilterType.ExperienceCategory.rawValue ||
            self.tag == FilterType.ExperienceTags.rawValue ||
            self.tag == FilterType.VillaType.rawValue ||
            self.tag == FilterType.VillaLifeStyle.rawValue {   //event category, tags, villa types and lifeStyles
                self.loadPickerItems(textField: textField)
                return false
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //it will work for yacht
        if self.tag == FilterType.YachtTags.rawValue || self.tag == FilterType.VillaTags.rawValue{
            if let text = textField.text{
                var _temp = self.pickedItems
                _temp.append(Taxonomy(termId: "-123", name: text))
                self.pickedItems = _temp  //it will reload
                self.txtName.text = ""
                // Do not add a line break
                return false
            }
        }
        return true
    }
}
