//
//  FiltersViewController.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
// zahoor

import UIKit


protocol FiltersVCProtocol:class {
    func setFirstFilter(filter:String)      //name
    func setSecondFilter(filter:Taxonomy?)  //daily or weekly charter
    func setThirdFilter(filter:String)
    func setFourthFilter(filter:Taxonomy?)
    func setFifthFilter(filter:Taxonomy?)
    func setSixthFilter(filter:Taxonomy?)
    func setSeventhFilter(filter:String)
    func setEighthFilter(filter:Taxonomy?)  //yacht tag
    func setNinthFilter(filter:Taxonomy?)   //charter or sale
    func setTenthFilter(filter:Taxonomy?)   //region
    func setEleventhFilter(filter:String)    //min price
    func setTwelvethFilter(filter:String)    //mx price
}

class FiltersViewController: UIViewController {
    
    //MARK:- Globals
    
    private(set) var filters: [Filters]!
    private(set) var category: ProductCategory!
    
    class var identifier: String { return "FiltersViewController" }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    
    var delegate:FiltersVCProtocol?     //used to set the filters
    
    /// Init method that will init and return view controller.
    class func instantiate(filters: [Filters], category: ProductCategory) -> FiltersViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! FiltersViewController
        viewController.filters = filters
        viewController.category = category
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(back(sender:)))
        newBackButton.image = UIImage(named: "Back Button Top")
        self.navigationItem.leftBarButtonItem = newBackButton
        self.title = category.rawValue + " filters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllTapped))
        updateContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    

    @objc func back(sender: UIBarButtonItem) {
        print("Clear all filters")
        clearAllFilters()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func clearAllTapped() {
        clearAllFilters()
        updateContent()
    }
    
    func clearAllFilters(){
        delegate?.setFirstFilter(filter: "")
        delegate?.setSecondFilter(filter: nil)
        delegate?.setThirdFilter(filter: "")
        delegate?.setFourthFilter(filter: nil)
        delegate?.setFifthFilter(filter: nil)
        delegate?.setSixthFilter(filter: nil)
        delegate?.setSeventhFilter(filter: "")
        delegate?.setEighthFilter(filter: nil)
        delegate?.setNinthFilter(filter: nil)
        delegate?.setTenthFilter(filter: nil)
        delegate?.setEleventhFilter(filter: "")
        delegate?.setTwelvethFilter(filter: "")
    }
    
    func updateYachtFilters(_ previousViewController: UIViewController){
        let view = TextFieldFilter()
        view.lblTitle.text = "Yacht name"
        view.viewPicker.isHidden = true
        view.tag = 1

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.firstFilter.count > 0{
            view.txtName.text = viewController.firstFilter
        }
        stackView.addArrangedSubview(view)

//        if var items = self.filters.yachtStatus , items.count > 0{
            let viewInterestedIn = SingleLineCollectionFilter()
        viewInterestedIn.lblTitle.text = "Interested In"

            //To pre-fill with existing filters
            //if previous VC is percity and second filter was set
//            if let viewController = previousViewController as? PerCityViewController , viewController.ninthFilter.count != 0 {
//                for (index, element) in items.enumerated() {
//                    if element.termId == viewController.ninthFilter[0].termId{
//                        items[index].isSelected = true
//                    }
//                }
//            }

            //viewInterestedIn.items = items
            viewInterestedIn.items = [Taxonomy(termId: "-123", name: "Purchase")]
            view.tag = 8
            viewInterestedIn.delegate = self    //it will cause the tap event on radio button fire which will hide unhide yacht charter view
            stackView.addArrangedSubview(viewInterestedIn)
//        }

//        if var items = self.filters.yachtCharterType , items.count > 0{
            let viewCharterType = SingleLineCollectionFilter()
        viewCharterType.lblTitle.text = "Charter"

            //To pre-fill with existing filters
            //if previous VC is percity and second filter was set
//            if let viewController = previousViewController as? PerCityViewController , viewController.secondFilter.count != 0 {
//                for (index, element) in items.enumerated() {
//                    if element.termId == viewController.secondFilter[0].termId{
//                        items[index].isSelected = true
//                    }
//                }
//            }

//            viewCharterType.items = items
            viewCharterType.items = [Taxonomy(termId: "-123", name: "Daily"), Taxonomy(termId: "-123", name: "Weekly")]
            viewCharterType.tag = 2
            if let viewController = previousViewController as? PerCityViewController , viewController.ninthFilter.count != 0{
                //if user had selected *purchase* in interest in
                let termID = viewController.ninthFilter[0].termId
                print("Apply the below check")
//                        if (termID == 3023 || termID == 273 ){ //3023 = Sale on production and 273 = sale on staging
//                            view.isHidden = true    //Hide yacht charter view if user is interested in purchase
//                        }
            }
            stackView.addArrangedSubview(viewCharterType)
//        }

        let viewRegion = TextFieldFilter()
        viewRegion.lblTitle.text = "Region"
        viewRegion.viewPicker.isHidden = true
        viewRegion.tag = 9

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.tenthFilter != nil {
            viewRegion.txtName.text = viewController.tenthFilter?.name
        }
        stackView.addArrangedSubview(viewRegion)

        let viewGuests = TextFieldFilter()
        viewGuests.lblTitle.text = "Guests"
        viewGuests.items = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51-100", "101-150", "151-200", "200+"]]
        viewGuests.txtName.isHidden = true
        viewGuests.tag = 3
        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.thirdFilter.count > 0{
            viewGuests.lblPickerSelection.text = viewController.thirdFilter
            viewGuests.txtPickerSelection = viewController.thirdFilter
        }
        stackView.addArrangedSubview(viewGuests)

//        if ((self.filters.yachtLengthInFeet?.count ?? 0 > 0) || (self.filters.yachtLengthInMeter?.count ?? 0 > 0)){
            let viewYachtLength = YachtLengthFilter()
//            if var items = self.filters.yachtLengthInFeet{
//                //To pre-fill with existing filters
//                //if previous VC is percity and second filter was set
//                if let viewController = previousViewController as? PerCityViewController , viewController.fourthFilter != nil {
//                    for (index, element) in items.enumerated() {
//                        if element.termId == viewController.fourthFilter?.termId{
//                            items[index].isSelected = true
//                        }
//                    }
//                }
//                viewYachtLength.feet = items
        viewYachtLength.feet = [Taxonomy(termId: "-123", name: "30-40"), Taxonomy(termId: "-123", name: "41-60")]
//            }
//            if var items = self.filters.yachtLengthInMeter{
//                //To pre-fill with existing filters
//                //if previous VC is percity and second filter was set
//                if let viewController = previousViewController as? PerCityViewController , viewController.fifthFilter != nil {
//                    for (index, element) in items.enumerated() {
//                        if element.termId == viewController.fifthFilter?.termId{
//                            items[index].isSelected = true
//                        }
//                    }
//                }
//                viewYachtLength.meters = items
        viewYachtLength.meters = [Taxonomy(termId: "-123", name: "10-13"), Taxonomy(termId: "-123", name: "14-20")]
//            }
            viewYachtLength.tag = 4
            stackView.addArrangedSubview(viewYachtLength)
//        }

//        if var items = self.filters.yachtType , items.count > 0{
            let viewYachtType = SingleLineCollectionFilter()
        viewYachtType.lblTitle.text = "Type"

            //To pre-fill with existing filters
            //if previous VC is percity and second filter was set
//            if let viewController = previousViewController as? PerCityViewController , viewController.sixthFilter.count != 0{
//                for (index, element) in items.enumerated() {
//                    if element.termId == viewController.sixthFilter[0].termId{
//                        items[index].isSelected = true
//                    }
//                }
//            }

//            viewYachtType.items = items
            viewYachtType.items = [Taxonomy(termId: "-123", name: "Motor"), Taxonomy(termId: "-123", name: "Sail")]
            viewYachtType.tag = 5
            stackView.addArrangedSubview(viewYachtType)
//        }

        let viewBuiltAfter = TextFieldFilter()
        viewBuiltAfter.lblTitle.text = "Built after"
        viewBuiltAfter.items = [["1987", "1988", "1989", "1990", "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021"]]
        viewBuiltAfter.txtName.isHidden = true
        viewBuiltAfter.tag = 6
        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.seventhFilter.count > 0{
            viewBuiltAfter.lblPickerSelection.text = viewController.seventhFilter
            viewBuiltAfter.txtPickerSelection = viewController.seventhFilter
        }
        stackView.addArrangedSubview(viewBuiltAfter)

        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = 10

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.eleventhFilter.count > 0{
            viewMinMax.txtMinimum.text = viewController.eleventhFilter
        }
        if let viewController = previousViewController as? PerCityViewController , viewController.twelvethFilter.count > 0{
            viewMinMax.txtMaximum.text = viewController.twelvethFilter
        }
        stackView.addArrangedSubview(viewMinMax)

//        if let items = self.filters.yachtTag , items.count > 0{
            let viewYachtTag = SingleLineCollectionFilter()
            viewYachtTag.isTagLookAlike = true
            viewYachtTag.lblTitle.text = "Tag"
//            viewYachtTag.items = items
            viewYachtTag.items = [Taxonomy(termId: "-123", name: "New"), Taxonomy(termId: "-123", name: "Luxury")]
            viewYachtTag.tag = 7
            stackView.addArrangedSubview(viewYachtTag)
//        }
    }
    
    func updateEventsExperiencesFilters(type: String ,_ previousViewController: UIViewController){
        
        if let items = self.filters , items.count > 0{
            let view = SingleLineCollectionFilter()
            view.isTagLookAlike = true
            view.lblTitle.text = "Featured " + (type == "Event" ? "events" : "experiences")
            view.items = [Taxonomy(termId: "-123" , name: "Drift"), Taxonomy(termId: "-123" , name: "Awesome")]
            view.tag = 7
            stackView.addArrangedSubview(view)
        }
        
        let viewName = TextFieldFilter()
        viewName.lblTitle.text = (type == "Event" ? "Event" : "Experience") + " name"
        viewName.txtName.placeholder = "Enter Keywords"
        viewName.viewPicker.isHidden = true
        viewName.tag = 2

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.secondFilter.count > 0{
            viewName.txtName.text = viewController.firstFilter
        }
        stackView.addArrangedSubview(viewName)
        
        let viewRegion = TextFieldFilter()
        viewRegion.lblTitle.text = "Location"
        viewRegion.txtName.placeholder = "Enter region"
        viewRegion.viewPicker.isHidden = true
        viewRegion.tag = 3

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.thirdFilter != nil {
            viewRegion.txtName.text = ""//viewController.secondFilter.name
        }
        stackView.addArrangedSubview(viewRegion)
        //**********
        //NEW FILTER
        //**********
        let airportCollViewCell = AirportCollViewCell()
        let viewCategory = MultiLineCollectionFilter(cell: airportCollViewCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
        viewCategory.lblTitle.text = "Category"
        viewCategory.txtName.placeholder = "Select Category"
        viewCategory.items = [Taxonomy(termId: "-123" , name: "Adventure") , Taxonomy(termId: "-123" , name: "Arts")]
        viewCategory.tag = 4

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.fourthFilter != nil {
//            viewCategory.txtName.text = ""//viewController.secondFilter.name
        }
        stackView.addArrangedSubview(viewCategory)
        
        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = 5

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.eleventhFilter.count > 0{
            viewMinMax.txtMinimum.text = viewController.eleventhFilter
        }
        if let viewController = previousViewController as? PerCityViewController , viewController.twelvethFilter.count > 0{
            viewMinMax.txtMaximum.text = viewController.twelvethFilter
        }
        stackView.addArrangedSubview(viewMinMax)
        
        if let items = self.filters , items.count > 0{
            let airportCollViewCell = AirportCollViewCell()
            let view = MultiLineCollectionFilter(cell: airportCollViewCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
            view.isTagLookAlike = true
            view.lblTitle.text = "Tags"
            view.txtName.placeholder = "Enter tags here"
            view.items = [Taxonomy(termId: "-123" , name: "Sports") , Taxonomy(termId: "-123" , name: "Arts")]
            view.tag = 7
            stackView.addArrangedSubview(view)
        }

    }
    
    func updateGiftsFilters(_ previousViewController: UIViewController){
        //**********
        //NEW FILTER
        //**********
        let giftCell = GiftFilterCell()
        let sortByFilter = MultiLineCollectionFilter(cell: giftCell, cellWidth: 400, cellHeight: 36, scrollDirection: .vertical, leftImageName: "", rightImageName: "filters_uncheck")
        sortByFilter.lblTitle.text = "Sort By"
        sortByFilter.txtName.isHidden = true
        sortByFilter.items = [Taxonomy(termId: "-123" , name: "Our Picks"),
                              Taxonomy(termId: "-123" , name: "New Items"),
                              Taxonomy(termId: "-123" , name: "Price (low first)"),
                              Taxonomy(termId: "-123" , name: "Price (high first)")]
        sortByFilter.tag = 1

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.fourthFilter != nil {
//            viewCategory.txtName.text = ""//viewController.secondFilter.name
        }
        stackView.addArrangedSubview(sortByFilter)
        
        //**********
        //NEW FILTER
        //**********
        let filterByCell = GiftFilterCell()
        let filterByFilter = MultiLineCollectionFilter(cell: filterByCell, cellWidth: 400, cellHeight: 36, scrollDirection: .vertical, leftImageName: "", rightImageName: "filters_check")
        filterByFilter.lblTitle.text = "Filter By"
        filterByFilter.txtName.isHidden = true
        filterByFilter.items = [Taxonomy(termId: "-123" , name: "Brands"),
                              Taxonomy(termId: "-123" , name: "Categories"),
                              Taxonomy(termId: "-123" , name: "Colors")]
        filterByFilter.tag = 1

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.fourthFilter != nil {
//            viewCategory.txtName.text = ""//viewController.secondFilter.name
        }
        stackView.addArrangedSubview(filterByFilter)
        //**********
        //NEW FILTER
        //**********
        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = 10

        //pre-filling with existing filters
        if let viewController = previousViewController as? PerCityViewController , viewController.eleventhFilter.count > 0{
            viewMinMax.txtMinimum.text = viewController.eleventhFilter
        }
        if let viewController = previousViewController as? PerCityViewController , viewController.twelvethFilter.count > 0{
            viewMinMax.txtMaximum.text = viewController.twelvethFilter
        }
        stackView.addArrangedSubview(viewMinMax)
    }
    
    func updateContent() {
        for view in self.stackView.subviews {
            view.removeFromSuperview()
        }
        let i = navigationController?.viewControllers.firstIndex(of: self)
        if let previousViewController = navigationController?.viewControllers[i!-1]{
            switch category {
            case .yacht:
                updateYachtFilters(previousViewController)
                break
            case .event:
                updateEventsExperiencesFilters(type: "Event", previousViewController)
            case .experience:
                updateEventsExperiencesFilters(type: "Experience", previousViewController)
                break
            case .gift:
                updateGiftsFilters(previousViewController)
                break
            default:
                break
            }
        }

    }
    
    func setupFilterLayout(textFieldFilter:TextFieldFilter){
        textFieldFilter.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        textFieldFilter.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        //top isnt required as in stack view it doesnt matter
        //wishListView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 100).isActive = true
        textFieldFilter.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        let itemHeight = 96
//        print(itemHeight)
        textFieldFilter.heightAnchor.constraint(equalToConstant: CGFloat(itemHeight)).isActive = true

    }
    
    
    @IBAction func btnApplyTapped(_ sender: Any) {
        clearAllFilters()   //first clear all filters, then set new filters
        for view in stackView.subviews{
            if view is TextFieldFilter{
                if let v = view as? TextFieldFilter , let txt = v.txtName.text, txt.count > 0{
                    if (v.tag == 1){    //user has entered some thing in the text field yacht name
                        delegate?.setFirstFilter(filter: txt )
                    }else if (v.tag == 9){    //user has selected region
                        delegate?.setTenthFilter(filter: v.selectedItem)
                    }
                }else if let v = view as? TextFieldFilter , let txt = v.txtPickerSelection, txt.count > 0{
                    if (v.tag == 3){    //user has selected something from yacht guest
                        delegate?.setThirdFilter(filter: txt)
                    }else if (v.tag == 6){    //user has selected something from built after
                        delegate?.setSeventhFilter(filter: txt)
                    }
                }
                
            }else if view is SingleLineCollectionFilter{
                let v = view as! SingleLineCollectionFilter
                let items = v.items.filter({$0.isSelected == true})
                if (items.count == 1){  //so far user can select only 1 filter
                    if (v.tag == 2){    //user has selected something from yacht charter, charter would be hidden if user is intersted in yacht purchase
                        if (v.isHidden == false){
                            delegate?.setSecondFilter(filter: items[0]) //set yacht charter if view is not hidden i.e. user has selected some thing
                        }else{
                            delegate?.setSecondFilter(filter: nil)      //unset if user is not selecting any thing on yacht charter
                        }
                        
                    }else if (v.tag == 5){    //user has selected something from yacht type
                        delegate?.setSixthFilter(filter: items[0])
                    }else if (v.tag == 7){    //user has selected something from yacht tag
                        delegate?.setEighthFilter(filter: items[0])
                    }else if (v.tag == 8){    //user has selected something from Interested in, yacht charter or yacht purchase
                        delegate?.setNinthFilter(filter: items[0])
                    }
                }
            }
            else if view is YachtLengthFilter{
                let v = view as! YachtLengthFilter
                var items = v.feet.filter({$0.isSelected == true})
                if (items.count == 1 && v.tag == 4){  //so far user can select only 1 filter, selected from feet
                    delegate?.setFourthFilter(filter: items[0])
//                    delegate?.setFifthFilter(filter: nil)
                }
                items = v.meters.filter({$0.isSelected == true})
                if (items.count == 1 && v.tag == 4){  //so far user can select only 1 filter, selected from meters
//                    delegate?.setFourthFilter(filter: nil)
                    delegate?.setFifthFilter(filter: items[0])
                }
            }else if view is MinMaxFilter{
                if let v = view as? MinMaxFilter , let txt = v.txtMinimum.text, txt.count > 0{
                    if (v.tag == 10){    //user has entered some thing in the text field min price
                        delegate?.setEleventhFilter(filter: txt )
                    }
                }
                if let v = view as? MinMaxFilter , let txt = v.txtMaximum.text, txt.count > 0{
                    if (v.tag == 10){    //user has entered some thing in the text field max price
                        delegate?.setTwelvethFilter(filter: txt )
                    }
                }
                
            }
            else{
                print("Some other")
            }
        }
        
        
        //popping up the VC
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

extension FiltersViewController:SingleLineCollectionFilterProtocol{
    
    func didTappedOnFilterAt(tag: Int, termId: String) {
        if (tag == 8){
            for view in stackView.subviews{
                if view is SingleLineCollectionFilter, view.tag == 2{
                    print("add termid check commented below")
//                    if termId == 272 || termId == 3022{         // 272 = rent on staging, 3022 = rent on production
//                        view.isHidden = false
//                    }else if termId == 273 || termId == 3023{   // 273 = sale on staging, 3023 = sale on production
//                        view.isHidden = true
//                    }
                }
            }
        }
    }
    
    
}
