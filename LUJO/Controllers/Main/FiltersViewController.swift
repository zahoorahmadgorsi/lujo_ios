//
//  FiltersViewController.swift
//  LUJO
//
//  Created by iMac on 22/10/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
// zahoor

import UIKit


protocol FiltersVCProtocol:class {
    func setCities(cities:[String])
//    func setFirstFilter(filter:String)      //name
//    func setSecondFilter(filter:Taxonomy?)  //daily or weekly charter
//    func setThirdFilter(filter:String)
//    func setFourthFilter(filter:Taxonomy?)
//    func setFifthFilter(filter:Taxonomy?)
//    func setSixthFilter(filter:Taxonomy?)
//    func setSeventhFilter(filter:String)
//    func setEighthFilter(filter:Taxonomy?)  //yacht tag
//    func setNinthFilter(filter:Taxonomy?)   //charter or sale
//    func setTenthFilter(filter:Taxonomy?)   //region
//    func setEleventhFilter(filter:String)    //min price
//    func setTwelvethFilter(filter:String)    //mx price
}

enum FilterType: Int {
    case FeaturedEvents = 1, EventName, EventLocation, EventCategory, EventPrice, EventTags, ExperienceCategory, ExperienceTags,
        YachtPopularLocations, YachtName, YachtStatus, YachtCharter, YachtRegion, YachtGuests, YachtLength, YachtType, YachtBuiltAfter, YachtPrice, YachtTags,
         VillaFeaturedLocations, VillaLocation, VillaSaleType, VillaGuests, VillaType, VillaLifeStyle, VillaPrice, VillaBedRooms, VillaBathRooms, VillaTags
        
}

class FiltersViewController: UIViewController {
    
    //MARK:- Globals
    
    private(set) var filters: [Filters]!
    private(set) var category: ProductCategory!
    
    class var identifier: String { return "FiltersViewController" }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    

    
//    var delegate:FiltersVCProtocol?     //used to set the filters
    
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
        //self.title = category.rawValue + " filters"
        self.title = "Filters"
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
//        delegate?.setFirstFilter(filter: "")
//        delegate?.setSecondFilter(filter: nil)
//        delegate?.setThirdFilter(filter: "")
//        delegate?.setFourthFilter(filter: nil)
//        delegate?.setFifthFilter(filter: nil)
//        delegate?.setSixthFilter(filter: nil)
//        delegate?.setSeventhFilter(filter: "")
//        delegate?.setEighthFilter(filter: nil)
//        delegate?.setNinthFilter(filter: nil)
//        delegate?.setTenthFilter(filter: nil)
//        delegate?.setEleventhFilter(filter: "")
//        delegate?.setTwelvethFilter(filter: "")
    }
    
    func updateYachtFilters(_ previousViewController: UIViewController){
        //************************
        // Yacht Popular Locations
        //************************
        if let items = self.filters , items.count > 0{
            let view = SingleLineCollectionFilter()
            view.isTagLookAlike = true
            view.lblTitle.text = "Popular charter locations"
            
            let citiesFilter = self.filters.filter({$0.key == "countries"})
            if citiesFilter.count > 0, let options = citiesFilter[0].options, options.count > 0{
                view.items = options
            }
            view.tag = FilterType.YachtPopularLocations.rawValue
            stackView.addArrangedSubview(view)
        }
        //***********
        // Yacht Name
        //***********
        let view = TextFieldFilter()
        view.lblTitle.text = "Yacht name"
        view.viewPicker.isHidden = true
        view.tag = FilterType.YachtName.rawValue

        stackView.addArrangedSubview(view)
        //**************************
        // Yacht Status Charter/Sale
        //**************************
        var items = self.filters.filter({$0.key == "yacht_status"})
        if  items.count > 0, let options = items[0].options, options.count > 0{
            let viewInterestedIn = SingleLineCollectionFilter()
            viewInterestedIn.lblTitle.text = items[0].name

            viewInterestedIn.items = options
            viewInterestedIn.tag = FilterType.YachtStatus.rawValue
            viewInterestedIn.delegate = self    //it will cause the tap event on radio button fire which will hide unhide yacht charter view
            stackView.addArrangedSubview(viewInterestedIn)
        }
        //*******************************
        // Yacht Charter Any/Daily/Weekly
        //*******************************
        items = self.filters.filter({$0.key == "charter_time"})
        if  items.count > 0, let options = items[0].options, options.count > 0{
            let viewCharterType = SingleLineCollectionFilter()
            viewCharterType.lblTitle.text = items[0].name

            viewCharterType.items = options
            viewCharterType.tag = FilterType.YachtCharter.rawValue
            viewCharterType.delegate = self    //it will cause the tap event on radio button fire which will hide unhide yacht charter view

            stackView.addArrangedSubview(viewCharterType)
        }
        //*************
        // Yacht Region
        //*************
        let viewRegion = TextFieldFilter()
        viewRegion.lblTitle.text = "Region"
        viewRegion.viewPicker.isHidden = true
        viewRegion.tag = FilterType.YachtRegion.rawValue

        stackView.addArrangedSubview(viewRegion)
        //*************
        // Yacht Guests
        //*************
        let viewGuests = TextFieldFilter()
        viewGuests.lblTitle.text = "Guests"
        viewGuests.items = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51-100", "101-150", "151-200", "200+"]]
        viewGuests.txtName.isHidden = true
        viewGuests.tag = FilterType.YachtGuests.rawValue

        stackView.addArrangedSubview(viewGuests)
        //*************
        // Yacht Length
        //*************
        let viewYachtLength = YachtLengthFilter()
        viewYachtLength.feet = [Taxonomy(termId: "-123", name: "30-40"), Taxonomy(termId: "-123", name: "41-60")]
        viewYachtLength.meters = [Taxonomy(termId: "-123", name: "9-13"), Taxonomy(termId: "-123", name: "14-20")]
        viewYachtLength.tag = FilterType.YachtLength.rawValue
        stackView.addArrangedSubview(viewYachtLength)
        //*************
        // Yacht Type
        //*************
        items = self.filters.filter({$0.key == "yacht_type"})
        if  items.count > 0, let options = items[0].options, options.count > 0{
            let viewInterestedIn = SingleLineCollectionFilter()
            viewInterestedIn.lblTitle.text = items[0].name

            viewInterestedIn.items = options
            viewInterestedIn.tag = FilterType.YachtType.rawValue
            viewInterestedIn.delegate = self    //it will cause the tap event on radio button fire which will hide unhide yacht charter view
            stackView.addArrangedSubview(viewInterestedIn)
        }
        //******************
        // Yacht Built After
        //******************
        let viewBuiltAfter = TextFieldFilter()
        viewBuiltAfter.lblTitle.text = "Built after"
        viewBuiltAfter.items = [["1987", "1988", "1989", "1990", "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022"]]
        viewBuiltAfter.txtName.isHidden = true
        viewBuiltAfter.tag = FilterType.YachtBuiltAfter.rawValue
        stackView.addArrangedSubview(viewBuiltAfter)
        //******************
        // Yacht Price
        //******************
        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = FilterType.YachtPrice.rawValue
        stackView.addArrangedSubview(viewMinMax)
        //**********
        //Yacht TAGS
        //**********
//        items = self.filters.filter({$0.key == "tags"})
        let tagsCell = AirportCollViewCell()
        let viewYachtTag = MultiLineCollectionFilter(cell: tagsCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
        viewYachtTag.isTagLookAlike = true
        viewYachtTag.lblTitle.text = "Tags"
        viewYachtTag.txtName.placeholder = "Enter tags"
        viewYachtTag.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        viewYachtTag.pickedItems = []//[Taxonomy(termId: "-123" , name: "Sports") , Taxonomy(termId: "-123" , name: "Arts")]
        viewYachtTag.tag = FilterType.YachtTags.rawValue
        stackView.addArrangedSubview(viewYachtTag)
    }
    
    func updateEventsExperiencesFilters(type: String ,_ previousViewController: UIViewController){
        //**********************
        // Event Featured Cities
        //**********************
        if let items = self.filters , items.count > 0{
            let view = SingleLineCollectionFilter()
            view.isTagLookAlike = true
            //view.lblTitle.text = "Featured " + (type == "Event" ? "events" : "experiences")
            view.lblTitle.text = "Featured cities"
            
            let citiesFilter = self.filters.filter({$0.key == "cities"})
            if citiesFilter.count > 0, let options = citiesFilter[0].options, options.count > 0{
                view.items = options
            }
            view.tag = self.category == .event ? FilterType.FeaturedEvents.rawValue : FilterType.FeaturedEvents.rawValue
            stackView.addArrangedSubview(view)
        }
        //*******************
        // Event Product Name
        //*******************
        let viewName = TextFieldFilter()
        viewName.lblTitle.text = (type == "Event" ? "Event" : "Experience") + " name"
        viewName.txtName.placeholder = "Enter Keywords"
        viewName.viewPicker.isHidden = true
        viewName.tag = FilterType.EventName.rawValue

        //pre-filling with existing filters
//        if let viewController = previousViewController as? PerCityViewController , viewController.secondFilter.count > 0{
//            viewName.txtName.text = viewController.firstFilter
//        }
        stackView.addArrangedSubview(viewName)
        //****************
        // Event Location
        //****************
        let viewRegion = TextFieldFilter()
        viewRegion.lblTitle.text = "Location"
        viewRegion.txtName.placeholder = "Enter city, state or country"
        viewRegion.viewPicker.isHidden = true
        viewRegion.tag = FilterType.EventLocation.rawValue

        //pre-filling with existing filters
//        if let viewController = previousViewController as? PerCityViewController , viewController.thirdFilter != nil {
//            viewRegion.txtName.text = ""//viewController.secondFilter.name
//        }
        stackView.addArrangedSubview(viewRegion)
        //***************
        // Event CATEGORY
        //***************
        let airportCollViewCell = AirportCollViewCell()
        let viewCategory = MultiLineCollectionFilter(cell: airportCollViewCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
        viewCategory.lblTitle.text = "Category"
        viewCategory.txtName.placeholder = "Select Category"
        viewCategory.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        viewCategory.pickedItems = []
        viewCategory.tag = self.category == .event ? FilterType.EventCategory.rawValue : FilterType.ExperienceCategory.rawValue
        stackView.addArrangedSubview(viewCategory)
        
        //***********
        //EVENT PRICE
        //***********
        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = FilterType.EventPrice.rawValue
        //pre-filling with existing filters
//        if let viewController = previousViewController as? PerCityViewController , viewController.eleventhFilter.count > 0{
//            viewMinMax.txtMinimum.text = viewController.eleventhFilter
//        }
//        if let viewController = previousViewController as? PerCityViewController , viewController.twelvethFilter.count > 0{
//            viewMinMax.txtMaximum.text = viewController.twelvethFilter
//        }
        stackView.addArrangedSubview(viewMinMax)
        //**********
        //Event TAGS
        //**********
        let tagsCell = AirportCollViewCell()
        let view = MultiLineCollectionFilter(cell: tagsCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
//            view.isTagLookAlike = true
        view.lblTitle.text = "Tags"
        view.txtName.placeholder = "Select tags"
        viewCategory.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        view.pickedItems = []//[Taxonomy(termId: "-123" , name: "Sports") , Taxonomy(termId: "-123" , name: "Arts")]
        view.tag = self.category == .event ?  FilterType.EventTags.rawValue : FilterType.ExperienceTags.rawValue
        stackView.addArrangedSubview(view)
    }
    
    func updateGiftsFilters(_ previousViewController: UIViewController){
        //**********
        //NEW FILTER
        //**********
        let giftCell = GiftFilterCell()
        let sortByFilter = MultiLineCollectionFilter(cell: giftCell, cellWidth: 400, cellHeight: 36, scrollDirection: .vertical, leftImageName: "", rightImageName: "filters_uncheck")
        sortByFilter.lblTitle.text = "Sort By"
        sortByFilter.txtName.isHidden = true
        sortByFilter.pickedItems = [Taxonomy(termId: "-123" , name: "Our Picks"),
                              Taxonomy(termId: "-123" , name: "New Items"),
                              Taxonomy(termId: "-123" , name: "Price (low first)"),
                              Taxonomy(termId: "-123" , name: "Price (high first)")]
        sortByFilter.tag = 1

        //pre-filling with existing filters
//        if let viewController = previousViewController as? PerCityViewController , viewController.fourthFilter != nil {
////            viewCategory.txtName.text = ""//viewController.secondFilter.name
//        }
        stackView.addArrangedSubview(sortByFilter)
        
        //**********
        //NEW FILTER
        //**********
        let filterByCell = GiftFilterCell()
//        let filterByCell = CollectionInsideCell()
        let filterByFilter = MultiLineCollectionFilter(cell: filterByCell, cellWidth: 400, cellHeight: 36, scrollDirection: .vertical, leftImageName: "", rightImageName: "filter_right_arrow")
        filterByFilter.lblTitle.text = "Filter By"
        filterByFilter.txtName.isHidden = true
        filterByFilter.pickedItems = [Taxonomy(termId: "-123" , name: "Brands"),
                              Taxonomy(termId: "-123" , name: "Categories"),
                              Taxonomy(termId: "-123" , name: "Colors")]
        filterByFilter.tag = 1

        //pre-filling with existing filters
//        if let viewController = previousViewController as? PerCityViewController , viewController.fourthFilter != nil {
////            viewCategory.txtName.text = ""//viewController.secondFilter.name
//        }
        stackView.addArrangedSubview(filterByFilter)
        //**********
        //NEW FILTER
        //**********
        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = 10

        //pre-filling with existing filters
//        if let viewController = previousViewController as? PerCityViewController , viewController.eleventhFilter.count > 0{
//            viewMinMax.txtMinimum.text = viewController.eleventhFilter
//        }
//        if let viewController = previousViewController as? PerCityViewController , viewController.twelvethFilter.count > 0{
//            viewMinMax.txtMaximum.text = viewController.twelvethFilter
//        }
        stackView.addArrangedSubview(viewMinMax)
    }
    
    func updateVillaFilters(_ previousViewController: UIViewController){
        //************************
        // Yacht Popular Locations
        //************************
        if let items = self.filters , items.count > 0{
            let view = SingleLineCollectionFilter()
            view.isTagLookAlike = true
            view.lblTitle.text = "Featured locations"
            
            let citiesFilter = self.filters.filter({$0.key == "cities"})
            if citiesFilter.count > 0, let options = citiesFilter[0].options, options.count > 0{
                view.items = options
            }
            view.tag = FilterType.VillaFeaturedLocations.rawValue
            stackView.addArrangedSubview(view)
        }
        //***************
        // Villa Location
        //***************
        let viewRegion = TextFieldFilter()
        viewRegion.lblTitle.text = "Location"
        viewRegion.txtName.placeholder = "Enter Location"
        viewRegion.viewPicker.isHidden = true
        viewRegion.tag = FilterType.VillaLocation.rawValue
        stackView.addArrangedSubview(viewRegion)
        //**************************
        // Villa Rent/Sale
        //**************************
        var items = self.filters.filter({$0.key == "sales_type"})
        if  items.count > 0, let options = items[0].options, options.count > 0{
            let viewInterestedIn = SingleLineCollectionFilter()
            viewInterestedIn.lblTitle.text = items[0].name

            viewInterestedIn.items = options
            viewInterestedIn.tag = FilterType.VillaSaleType.rawValue
            viewInterestedIn.delegate = self    //it will cause the tap event on radio button fire which will hide unhide yacht charter view
            stackView.addArrangedSubview(viewInterestedIn)
        }
        //******************
        // Villa Guests
        //******************
        let viewMinMax = MinMaxFilter()
        viewMinMax.isCurrency = false   //it will hide currency textview
        viewMinMax.lblTitle.text = "Guests"
        viewMinMax.tag = FilterType.VillaGuests.rawValue
        stackView.addArrangedSubview(viewMinMax)
        //***************
        // Villa Type
        //***************
        let airportCollViewCell = AirportCollViewCell()
        let viewCategory = MultiLineCollectionFilter(cell: airportCollViewCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
        viewCategory.lblTitle.text = "Type"
        viewCategory.txtName.placeholder = "Select"
        viewCategory.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        viewCategory.pickedItems = []
        viewCategory.tag = FilterType.VillaType.rawValue
        stackView.addArrangedSubview(viewCategory)
        //*****************
        // Villa Life Style
        //*****************
        let lifeStyleCollViewCell = AirportCollViewCell()
        let villaLifeStyle = MultiLineCollectionFilter(cell: lifeStyleCollViewCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
        villaLifeStyle.lblTitle.text = "Lifestyle"
        villaLifeStyle.txtName.placeholder = "Select"
        villaLifeStyle.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        villaLifeStyle.pickedItems = []
        villaLifeStyle.tag = FilterType.VillaLifeStyle.rawValue
        stackView.addArrangedSubview(villaLifeStyle)
        //************
        // Villa Price
        //************
        let viewVillaPrice = MinMaxFilter()
        viewVillaPrice.lblTitle.text = "Price"
        viewVillaPrice.tag = FilterType.VillaPrice.rawValue
        stackView.addArrangedSubview(viewVillaPrice)
        //******************
        // Villa Bed Rooms
        //******************
        let viewVillaBedRooms = MinMaxFilter()
        viewVillaBedRooms.isCurrency = false   //it will hide currency textview
        viewVillaBedRooms.lblTitle.text = "No. of Bedrooms"
        viewVillaBedRooms.tag = FilterType.VillaBedRooms.rawValue
        stackView.addArrangedSubview(viewVillaBedRooms)
        //******************
        // Villa Bath Rooms
        //******************
        let viewVillaBathRooms = MinMaxFilter()
        viewVillaBathRooms.isCurrency = false   //it will hide currency textview
        viewVillaBathRooms.lblTitle.text = "No. of Bathrooms"
        viewVillaBathRooms.tag = FilterType.VillaBathRooms.rawValue
        stackView.addArrangedSubview(viewVillaBathRooms)
        //**********
        // Villa TAGS
        //**********
//        items = self.filters.filter({$0.key == "tags"})
        let tagsCell = AirportCollViewCell()
        let viewYachtTag = MultiLineCollectionFilter(cell: tagsCell, cellWidth: 125, cellHeight: 36, scrollDirection: .horizontal)
        viewYachtTag.isTagLookAlike = true
        viewYachtTag.lblTitle.text = "Tags"
        viewYachtTag.txtName.placeholder = "Enter tags"
        viewYachtTag.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        viewYachtTag.pickedItems = []//[Taxonomy(termId: "-123" , name: "Sports") , Taxonomy(termId: "-123" , name: "Arts")]
        viewYachtTag.tag = FilterType.VillaTags.rawValue
        stackView.addArrangedSubview(viewYachtTag)
    }
    
    func updateContent() {
        for view in self.stackView.subviews {
            view.removeFromSuperview()
        }
        let i = navigationController?.viewControllers.firstIndex(of: self)
        if let previousViewController = navigationController?.viewControllers[i!-1]{
            switch category {
            case .villa:
                updateVillaFilters(previousViewController)
                break
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
        
        var _featuredCities:[String] = []
        var _productName:String = ""
        var _countryId:[String] = []
        var _categoryIds:[String] = []
        var _price: ProductPrice?
        var _tags:[String] = []
        var _yachtStatus:String = ""
        var _yachtCharter:String = ""
        var _regionId:String = ""
        var _guests:GuestsRange?
        var _yachtLength:YachtLength?
        var _yachtType:String = ""
        var _yachtBuiltAfter:String = ""
        var _villaSaleType:VillaSaleType?
        
        for view in stackView.subviews{
//            if category == .event || category == .experience || category == .yacht{
                //************************************************************
                //Featured Cities, YachtStatus, Charter, Type, Villa SaleType
                //***********************************************************
                if let v = view as? SingleLineCollectionFilter{
                    let items = v.items.filter({$0.isSelected == true})
                    for item in items{
                        if let value = item.value{
                            if v.tag == FilterType.YachtStatus.rawValue{
                                _yachtStatus = value
                            }else if v.tag == FilterType.YachtCharter.rawValue {
                                //yacht charter must not be hidden, if hidden mean yacht status "sale" is selected
                                if !v.isHidden{
                                    _yachtCharter = value
                                }
                            }else if v.tag == FilterType.YachtType.rawValue{
                                _yachtType = value
                            }else if v.tag == FilterType.YachtPopularLocations.rawValue{
                                _countryId.append(value)  //its working for key cities which is last else statement of thi code block
                            }else if v.tag == FilterType.VillaSaleType.rawValue{
                                if value.equals(rhs: "rent"){
                                    _villaSaleType = VillaSaleType(buy: false, rent: true)
                                }else if value.equals(rhs: "sale"){
                                    _villaSaleType = VillaSaleType(buy: true, rent: false)
                                }
                                
                            }
                            else{
                                _featuredCities.append(value)
                            }
                        }
                    }
                }
                //*******************************************************************
                //Product Name, Location Name, Yacht Name,region, guests, Built After
                //*******************************************************************
                else if let v = view as? TextFieldFilter{
                    if v.tag == FilterType.EventName.rawValue ||
                        v.tag == FilterType.YachtName.rawValue{  //Product name
                        if let text = v.txtName.text, text.count > 0{
                            _productName = text
                        }
                    }else if v.tag == FilterType.YachtGuests.rawValue {  //Guests
                        if let text = v.txtPickerSelection, text.count > 0{
                            _guests = getGuestsRange(range: text)
                        }
                    }else if v.tag == FilterType.YachtBuiltAfter.rawValue {  //Built After
                        if let text = v.txtPickerSelection, text.count > 0{
                            _yachtBuiltAfter = text
                        }
                    }else if v.tag == FilterType.EventLocation.rawValue || v.tag == FilterType.VillaLocation.rawValue{    //location name
                        if let selectedLocation = v.selectedItem{
                            if selectedLocation.country != nil{  //if country exist then user has searched a city
                                _featuredCities.append(selectedLocation.termId)
                            }else{
                                _countryId.append(selectedLocation.termId)
                            }
                        }
                    }else if v.tag == FilterType.YachtRegion.rawValue{    //in case of yacht region will become country, country will become city
                        if let selectedLocation = v.selectedItem{
                            if selectedLocation.yachtRegion != nil{     //if region exist then user has searched a country, else region
                                _countryId.append(selectedLocation.termId)
                            }else{
                                _regionId = selectedLocation.termId
                            }
                        }
                    }
                }
                //**********************************
                //Event Categories, Tags, Yacht Tags, Villa Types
                //**********************************
                else if let v = view as? MultiLineCollectionFilter{
                    let items = v.pickedItems
                    for item in items{
                        if v.tag == FilterType.EventCategory.rawValue || v.tag == FilterType.ExperienceCategory.rawValue{
                            _categoryIds.append(item.termId)
                        }else if v.tag == FilterType.EventTags.rawValue || v.tag == FilterType.ExperienceTags.rawValue {
                            _tags.append(item.termId)
                        }else if v.tag == FilterType.YachtTags.rawValue {
                            _tags.append(item.name)
                        }
                    }
                }
                //********************************
                //Event, Yacht Price, Villa Guests
                //********************************
                else if let v = view as? MinMaxFilter{
                    if v.tag == FilterType.EventPrice.rawValue || v.tag == FilterType.YachtPrice.rawValue{
                        if let code = v.selectedItem.code{
                            if let min = v.txtMinimum.text, let max = v.txtMaximum.text{
                                if  min.count > 0 , max.count > 0{
                                    _price = ProductPrice(currencyCode: code, minPrice: min, maxMax: max)
                                }else if !(min.count == 0 && max.count == 0){
                                    showCardAlertWith(title: "Price Filter", body: "Both min and max prices are required.")
                                    return
                                }
                            }
                        }
                    }else if v.tag == FilterType.VillaGuests.rawValue {
                        if let min = v.txtMinimum.text, let max = v.txtMaximum.text{
                            if  min.count > 0 , max.count > 0{
                                _guests = GuestsRange(from: min, to: max)
                            }else if !(min.count == 0 && max.count == 0){
                                showCardAlertWith(title: "Guest Filter", body: "Both min and max are required.")
                                return
                            }
                        }
                        
                    }
                }
                //************
                //Yacht Length
                //************
                else if view is YachtLengthFilter{
                    let v = view as! YachtLengthFilter
                    var items = v.feet.filter({$0.isSelected == true})
                    if (items.count == 1 && v.tag == FilterType.YachtLength.rawValue){  //selected from feet
                        _yachtLength = YachtLength(type: .FEET,
                                                   from: String(items[0].name.split(separator: "-")[0]),
                                                   to: String(items[0].name.split(separator: "-")[1]))
                    }else{ //if user has selected in meters and not in feet
                        items = v.meters.filter({$0.isSelected == true})
                        if (items.count == 1 && v.tag == FilterType.YachtLength.rawValue){  //so far user can select only 1 filter, selected from meters
                            _yachtLength = YachtLength(type: .METER,
                                                       from: String(items[0].name.split(separator: "-")[0]),
                                                       to: String(items[0].name.split(separator: "-")[1]))
                        }
                    }
                }
            }
//        }
        let _eventExperienceFilters = AppliedFilters(featuredCities: _featuredCities, productName: _productName, selectedCountry: _countryId, categoryIds: _categoryIds, price: _price, tagIds: _tags, yachtStatus: _yachtStatus, yachtCharter: _yachtCharter, selectedRegion: _regionId, guests:_guests, yachtLength: _yachtLength, yachtType: _yachtType, yachtBuiltAfter:_yachtBuiltAfter, villaSaleType: _villaSaleType)
        
        
        let viewController = ProductsViewController.instantiate(category: self.category, applyFilters: _eventExperienceFilters)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
//            if let v = view as? SingleLineCollectionFilter{
//                let v = view as! SingleLineCollectionFilter
//                let items = v.items.filter({$0.isSelected == true})
////                if (items.count == 1){  //so far user can select only 1 filter
//                    if (v.tag == 2){    //user has selected something from yacht charter, charter would be hidden if user is intersted in yacht purchase
//                        if (v.isHidden == false){
//                            delegate?.setSecondFilter(filter: items[0]) //set yacht charter if view is not hidden i.e. user has selected some thing
//                        }else{
//                            delegate?.setSecondFilter(filter: nil)      //unset if user is not selecting any thing on yacht charter
//                        }
//
//                    }else if (v.tag == 5){    //user has selected something from yacht type
//                        delegate?.setSixthFilter(filter: items[0])
//                    }else if (v.tag == 7){    //user has selected something from yacht tag
//                        delegate?.setEighthFilter(filter: items[0])
//                    }else if (v.tag == 8){    //user has selected something from Interested in, yacht charter or yacht purchase
//                        delegate?.setNinthFilter(filter: items[0])
//                    }
//                }
//            }
//            else
//            if view is TextFieldFilter{
//                if let v = view as? TextFieldFilter , let txt = v.txtName.text, txt.count > 0{
//                    if (v.tag == 1){    //user has entered some thing in the text field yacht name
//                        delegate?.setFirstFilter(filter: txt )
//                    }else if (v.tag == 9){    //user has selected region
//                        delegate?.setTenthFilter(filter: v.selectedItem)
//                    }
//                }else if let v = view as? TextFieldFilter , let txt = v.txtPickerSelection, txt.count > 0{
//                    if (v.tag == 3){    //user has selected something from yacht guest
//                        delegate?.setThirdFilter(filter: txt)
//                    }else if (v.tag == 6){    //user has selected something from built after
//                        delegate?.setSeventhFilter(filter: txt)
//                    }
//                }
//
//            }
//            else if view is YachtLengthFilter{
//                let v = view as! YachtLengthFilter
//                var items = v.feet.filter({$0.isSelected == true})
//                if (items.count == 1 && v.tag == 4){  //so far user can select only 1 filter, selected from feet
//                    delegate?.setFourthFilter(filter: items[0])
////                    delegate?.setFifthFilter(filter: nil)
//                }
//                items = v.meters.filter({$0.isSelected == true})
//                if (items.count == 1 && v.tag == 4){  //so far user can select only 1 filter, selected from meters
////                    delegate?.setFourthFilter(filter: nil)
//                    delegate?.setFifthFilter(filter: items[0])
//                }
//            }else if view is MinMaxFilter{
//                if let v = view as? MinMaxFilter , let txt = v.txtMinimum.text, txt.count > 0{
//                    if (v.tag == 10){    //user has entered some thing in the text field min price
//                        delegate?.setEleventhFilter(filter: txt )
//                    }
//                }
//                if let v = view as? MinMaxFilter , let txt = v.txtMaximum.text, txt.count > 0{
//                    if (v.tag == 10){    //user has entered some thing in the text field max price
//                        delegate?.setTwelvethFilter(filter: txt )
//                    }
//                }
//
//            }
//            else{
//                print("Some other")
//            }
//        }
        
        
        //popping up the VC
//        if let navController = self.navigationController {
//            navController.popViewController(animated: true)
//        }
//    }
    
    func getGuestsRange(range:String) -> GuestsRange?{
        let _guestsRange = range.split(separator: "-")
        var _from = "", _to = ""
        if _guestsRange.count > 0{
            _from  = String(_guestsRange[0])
            _to = _from //initially keep it same as from as in next code block _to is updating
        }
        if _guestsRange.count > 1{
            _to  =  String(_guestsRange[1])
        }
        if _from.count > 0{
            let _guestsRange = GuestsRange(from: _from , to: _to)
            return _guestsRange
        }else{
            return nil
        }
    }
}

extension FiltersViewController:SingleLineCollectionFilterProtocol{
    
    func didTappedOnFilterAt(tag: Int, tappedValue: String) {
        if (tag == FilterType.YachtStatus.rawValue){
            for view in stackView.subviews{
                if view is SingleLineCollectionFilter, view.tag == FilterType.YachtCharter.rawValue{
                    view.isHidden = tappedValue == "sale"    //if value of tapped item is sale then hide yachtCharter
                }
            }
        }
    }
    
    
}
