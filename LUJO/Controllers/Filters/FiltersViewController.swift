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
}

enum FilterType: Int {
    case FeaturedEvents = 1, EventName, EventLocation, EventCategory, EventPrice, EventTags, ExperienceCategory, ExperienceTags,
        YachtPopularLocations, YachtName, YachtStatus, YachtCharter, YachtRegion, YachtGuests, YachtLength, YachtType, YachtBuiltAfter, YachtPrice, YachtTags,
         VillaFeaturedLocations, VillaLocation, VillaSaleType, VillaGuests, VillaType, VillaLifeStyle, VillaPrice, VillaBedRooms, VillaBathRooms, VillaTags,
        GiftSortBy,GiftFilterBy,GiftPrice
        
}

class FiltersViewController: UIViewController {
    
    //MARK:- Globals
    
    private(set) var filters: [Filters]!
    private(set) var category: ProductCategory!
    
    class var identifier: String { return "FiltersViewController" }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    private var giftBrands = [Taxonomy]()
    private var giftCategories:[Taxonomy] = []
    private var giftSubCategoriess:[Taxonomy] = []
    private var giftColors:[Taxonomy] = []
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
        self.giftBrands = []
        self.giftCategories = []
        self.giftSubCategoriess = []
        self.giftColors = []
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
//        var items = self.filters.filter({$0.key == "yacht_status"})
//        if  items.count > 0, let options = items[0].options, options.count > 0{
//            let viewInterestedIn = SingleLineCollectionFilter()
//            viewInterestedIn.lblTitle.text = items[0].name
//
//            viewInterestedIn.items = options
//            viewInterestedIn.tag = FilterType.YachtStatus.rawValue
//            viewInterestedIn.delegate = self    //it will cause the tap event on radio button fire which will hide unhide yacht charter view
//            stackView.addArrangedSubview(viewInterestedIn)
//        }
        //*******************************
        // Yacht Charter Any/Daily/Weekly
        //*******************************
        var items = self.filters.filter({$0.key == "charter_time"})
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
        let viewYachtTag = MultiLineCollectionFilter(cell: tagsCell, cellWidth: 125, cellHeight: 36)
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
        let viewCategory = MultiLineCollectionFilter(cell: airportCollViewCell, cellWidth: 125, cellHeight: 36)
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
        let view = MultiLineCollectionFilter(cell: tagsCell, cellWidth: 125, cellHeight: 36)
//            view.isTagLookAlike = true
        view.lblTitle.text = "Tags"
        view.txtName.placeholder = "Select tags"
        view.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        view.pickedItems = []
        view.tag = self.category == .event ?  FilterType.EventTags.rawValue : FilterType.ExperienceTags.rawValue
        stackView.addArrangedSubview(view)
    }
    
    func updateGiftsFilters(){
        //**********
        // Sort By
        //**********
        let giftCell = GiftFilterCell()
        let sortByFilter = GiftsCollectionFilter(cell: giftCell, cellWidth: Int(UIScreen.main.bounds.width) - 32, cellHeight: 36, leftImageName: "", rightImageName: "filters_uncheck", filterCellType: FilterCellType.SortBy)
        sortByFilter.lblTitle.text = "Sort By"

        let sortByFilters = self.filters.filter({$0.key == "Sort By"})
        if sortByFilters.count > 0, let filterOptions = sortByFilters[0].options, filterOptions.count > 0{
            sortByFilter.pickedItems = createTaxonomiesFromFilters (filters: filterOptions )
        }
        sortByFilter.tag = FilterType.GiftSortBy.rawValue
        stackView.addArrangedSubview(sortByFilter)
        //**********
        // FILTER By
        //**********
        
        updateGiftsFilterByFilter(index: self.stackView.subviews.count)
        
        //**********
        //Price
        //**********
        let viewMinMax = MinMaxFilter()
        viewMinMax.lblTitle.text = "Price"
        viewMinMax.tag = FilterType.GiftPrice.rawValue
        stackView.addArrangedSubview(viewMinMax)
    }
    
    func updateGiftsFilterByFilter(index:Int){
        let filterByCell = GiftFilterCell()
        
        let filterByView = GiftsCollectionFilter(cell: filterByCell, cellWidth: Int(UIScreen.main.bounds.width) - 32, cellHeight: 36, leftImageName: "", rightImageName: "filter_right_arrow", filterCellType: FilterCellType.FilterBy)
        filterByView.lblTitle.text = "Filter By"

        let filterBy = self.filters.filter({$0.key == "filter by"})
        if filterBy.count > 0, let filterOptions = filterBy[0].options, filterOptions.count > 0{
            filterByView.pickedItems = createTaxonomiesFromFilters (filters: filterOptions )
        }
        filterByView.tag = FilterType.GiftFilterBy.rawValue
        filterByView.delegate = self
        stackView.insertArrangedSubview(filterByView, at: index)
    }
    
    private func createTaxonomiesFromFilters(filters: [filterOption]) -> [Taxonomy]{
        var taxonomies:[Taxonomy] = []
        var _count = 0
        for item in filters{
            _count = 0
            if var _name = item.name{
                if item.key == "brand", self.giftBrands.count > 0{
                    _count = self.giftBrands.count
                }else if item.key == "category", self.giftCategories.count > 0{
                    _count = self.giftCategories.count
                }else if item.key == "colors", self.giftColors.count > 0{
                    _count = self.giftColors.count
                }
                //append count of picked items from the filter i.e. brand, category
                _name = _count > 0 ? _name + " (\(_count))" : _name
                taxonomies.append( Taxonomy(id: item.key ?? "", name: _name, code: item.value ?? ""))
            }
        }
        return taxonomies
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
        let viewVillaType = MultiLineCollectionFilter(cell: airportCollViewCell, cellWidth: 125, cellHeight: 36)
        viewVillaType.lblTitle.text = "Type"
        viewVillaType.txtName.placeholder = "Select"
        //taking [options] out of [filters]
        if let filterOptions = self.filters.filter({$0.key == "property_type"}).map({$0.options})[0]{
            viewVillaType.items = createTaxonomiesFromFilters (filters: filterOptions )
        }
        viewVillaType.pickerItems = [[]] //by default nothing is picked hence collectionView space is not allocated
        viewVillaType.pickedItems = []
        viewVillaType.tag = FilterType.VillaType.rawValue
        stackView.addArrangedSubview(viewVillaType)
        //*****************
        // Villa Life Style
        //*****************
        let lifeStyleCollViewCell = AirportCollViewCell()
        let villaLifeStyle = MultiLineCollectionFilter(cell: lifeStyleCollViewCell, cellWidth: 125, cellHeight: 36)
        villaLifeStyle.lblTitle.text = "Lifestyle"
        villaLifeStyle.txtName.placeholder = "Select"
        //taking [options] out of [filters]
        if let filterOptions = self.filters.filter({$0.key == "lifestyle"}).map({$0.options})[0]{
            villaLifeStyle.items = createTaxonomiesFromFilters (filters: filterOptions )
        }
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
        let viewYachtTag = MultiLineCollectionFilter(cell: tagsCell, cellWidth: 125, cellHeight: 36)
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
                updateGiftsFilters()
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
//        clearAllFilters()   //first clear all filters, then set new filters
        
        var _featuredCities:[String] = []
        var _productName:String = ""
        var _countryId:[String] = []
        var _categoryIds:[String] = []
        var _price: ProductPrice?
        var _tags:[String] = []
        var _yachtStatus:String = ""
        var _yachtCharter:String = ""
        var _regionId:String = ""
        var _guests:AnyRange?
        var _yachtLength:YachtLength?
        var _yachtType:String = ""
        var _yachtBuiltAfter:String = ""
        var _villaSaleType:VillaSaleType?
        var _villaTypes:[String] = []
        var _villaLifeStyles:[String] = []
        var _bedRooms:AnyRange?
        var _bathRooms:AnyRange?
        //gift
        var _isFeature:Bool?
        var _orderByName: String?
        var _orderByPrice: String?
        
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
                //Product Name, Location Name, Yacht Name,region, guests, Built After, villa bedroom, bathrooms
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
                    }else if v.tag == FilterType.VillaBedRooms.rawValue {  //bedrooms
                        if let text = v.txtPickerSelection, text.count > 0{
                            _bedRooms = getGuestsRange(range: text)
                        }
                    }else if v.tag == FilterType.VillaBathRooms.rawValue {  //bathrooms
                        if let text = v.txtPickerSelection, text.count > 0{
                            _bathRooms = getGuestsRange(range: text)
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
                //****************************************************************
                //Event Categories, Tags, Yacht Tags, Villa Types, lifestyle, tags
                //****************************************************************
                else if let v = view as? MultiLineCollectionFilter{
                    let items = v.pickedItems
                    for item in items{
                        if v.tag == FilterType.EventCategory.rawValue ||
                           v.tag == FilterType.ExperienceCategory.rawValue{
                            _categoryIds.append(item.termId)
                        }else if v.tag == FilterType.EventTags.rawValue ||
                                 v.tag == FilterType.ExperienceTags.rawValue  {
                            _tags.append(item.termId)
                        }else if v.tag == FilterType.YachtTags.rawValue ||
                                 v.tag == FilterType.VillaTags.rawValue{
                            _tags.append(item.name)
                        }else if v.tag == FilterType.VillaType.rawValue {
                            _villaTypes.append(item.name)
                        }else if v.tag == FilterType.VillaLifeStyle.rawValue {
                            _villaLifeStyles.append(item.name)
                        }
                    }
                }
                //***************************************************
                //Event, Yacht Price, Villa Guests, Price, Gift Price
                //***************************************************
                else if let v = view as? MinMaxFilter{
                    if let min = v.txtMinimum.text, let max = v.txtMaximum.text{
                        if  min.count > 0 , max.count > 0{
                            if Int(min) ?? 0 > Int(max) ?? 0{
                                showCardAlertWith(title: "Min Max Filter", body: "Min must be less then the max.")
                                return
                            }else{
                                if v.tag == FilterType.EventPrice.rawValue ||
                                    v.tag == FilterType.YachtPrice.rawValue ||
                                    v.tag == FilterType.VillaPrice.rawValue ||
                                    v.tag == FilterType.GiftPrice.rawValue{
                                    if let code = v.selectedItem.code{
                                        _price = ProductPrice(currencyCode: code, minPrice: min, maxMax: max)
                                    }
                                }else if v.tag == FilterType.VillaGuests.rawValue{
                                    _guests = AnyRange(from: min, to: max)
                                }else if v.tag == FilterType.VillaBedRooms.rawValue {
                                    _bedRooms = AnyRange(from: min, to: max)
                                }else if v.tag == FilterType.VillaBathRooms.rawValue{
                                    _bathRooms = AnyRange(from: min, to: max)
                                }
                            }
                        }else if !(min.count == 0 && max.count == 0){
                            showCardAlertWith(title: "Min Max Filter", body: "Both min and max are required.")
                            return
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
                //************
                // Gift SortBy
                //************
                else if view is GiftsCollectionFilter{
                    let v = view as! GiftsCollectionFilter
                    if v.tag == FilterType.GiftSortBy.rawValue{
                        if let item = v.pickedItems.filter({$0.isSelected == true}).first{
                            if item.name == "Our Picks"{
                                _isFeature = true
                            }else if item.name == "New Items"{
                                _orderByName = item.code
                            }else if item.name == "Price(low first)" || item.name == "Price(high first)"{
                                _orderByPrice = item.code
                            }
                        }

                    }
                }
            }
//        }
        let _eventExperienceFilters = AppliedFilters(featuredCities: _featuredCities,
                                                     productName: _productName,
                                                     selectedCountry: _countryId,
                                                     categoryIds: _categoryIds,
                                                     price: _price,
                                                     tagIds: _tags,
                                                     yachtStatus: _yachtStatus,
                                                     yachtCharter: _yachtCharter,
                                                     selectedRegion: _regionId,
                                                     guests:_guests,
                                                     yachtLength: _yachtLength,
                                                     yachtType: _yachtType,
                                                     yachtBuiltAfter:_yachtBuiltAfter,
                                                     villaSaleType: _villaSaleType,
                                                     villaTypes: _villaTypes,
                                                     villaLifeStyle: _villaLifeStyles,
                                                     bedRooms: _bedRooms ,
                                                     bathRooms: _bathRooms ,
                                                     isFeature:_isFeature,
                                                     orderByName: _orderByName,
                                                     orderByPrice: _orderByPrice,
                                                     giftBrands: self.giftBrands.map{$0.termId},
                                                     giftCategories: self.giftCategories.map{ $0.termId },
                                                     giftSubCategoriess:self.giftSubCategoriess.map{ $0.termId },
                                                     giftColors: self.giftColors.map{ $0.termId })

        
        let viewController = ProductsViewController.instantiate(category: self.category, applyFilters: _eventExperienceFilters)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    
    func getGuestsRange(range:String) -> AnyRange?{
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
            let _guestsRange = AnyRange(from: _from , to: _to)
            return _guestsRange
        }else{
            return nil
        }
    }
}

extension FiltersViewController:SingleLineCollectionFilterProtocol{
    
    func didTappedOnFilterAt(tag: Int, tappedValue: String) {
//        if (tag == FilterType.YachtStatus.rawValue){
            for view in stackView.subviews{
                if view is SingleLineCollectionFilter, view.tag == FilterType.YachtCharter.rawValue{
                    view.isHidden = tappedValue == "sale"    //if value of tapped item is sale then hide yachtCharter
                }else if view is GiftsCollectionFilter, view.tag == FilterType.GiftFilterBy.rawValue{
                    if tappedValue == "brand"{
                        let viewController = BrandsViewController.instantiate(currentFilterType: .brands, alreadyPickedItems: self.giftBrands, delegate: self)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }else if tappedValue == "category"{
                        let viewController = BrandsViewController.instantiate(currentFilterType: .categories,  alreadyPickedItems: self.giftCategories, delegate: self)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }else if tappedValue == "colors"{
                        let viewController = BrandsViewController.instantiate(currentFilterType: .colors, alreadyPickedItems: self.giftColors, delegate: self)
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    
                }
            }
//        }
//        else if (tag == FilterType.GiftFilterBy.rawValue){
//            print(tag,tappedValue)
//        }
    }
}

extension FiltersViewController:BrandsSelectionProtocol{
    func passBackPickedItems(currentFilterType:GiftFilterType, pickedItems: [Taxonomy]) {
        switch currentFilterType{
        case .brands:
            self.giftBrands = pickedItems
        case .categories:
            self.giftCategories = pickedItems
        case .colors:
            self.giftColors = pickedItems
        }
//        if pickedItems.count > 0{
            //first removing all previous filter
        for view in self.stackView.subviews {
            if view.tag == FilterType.GiftFilterBy.rawValue{
                view.removeFromSuperview()
                updateGiftsFilterByFilter(index: self.stackView.subviews.count - 1)//update the name of filter by
                break
            }
        }
            
//        }
    }
    
    
}
