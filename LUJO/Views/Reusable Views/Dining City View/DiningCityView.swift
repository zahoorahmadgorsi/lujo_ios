//
//  DiningCityView.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

protocol DiningCityProtocol:class {
    func seeAllRestaurantsForCity(city: DiningCity, view: DiningCityView)
    func didTappedOnRestaurantAt(restaurant: Restaurant)
    func didTappedOnHeartAt(index: Int, sender: Restaurant)
}

class DiningCityView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var restaurant1ContainerView: UIView!
    @IBOutlet weak var restaurant1ImageView: UIImageView!
    @IBOutlet weak var restaurant1NameLabel: UILabel!
    @IBOutlet weak var restaurant1locationLabel: UILabel!
    @IBOutlet weak var restaurant1locationContainerView: UIView!
    @IBOutlet weak var restaurant1starCountLabel: UILabel!
    @IBOutlet weak var restaurant1starImageContainerView: UIView!
    @IBOutlet weak var imgHeart1: UIImageView!
    
    @IBOutlet weak var restaurant2ContainerView: UIView!
    @IBOutlet weak var restaurant2ImageView: UIImageView!
    @IBOutlet weak var restaurant2NameLabel: UILabel!
    @IBOutlet weak var restaurant2locationLabel: UILabel!
    @IBOutlet weak var restaurant2locationContainerView: UIView!
    @IBOutlet weak var restaurant2starCountLabel: UILabel!
    @IBOutlet weak var restaurant2starImageContainerView: UIView!
    @IBOutlet weak var imgHeart2: UIImageView!
    
    weak var delegate: DiningCityProtocol?
    
    var city: DiningCity? {
        didSet {
            setupViewUI()
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
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DiningCityView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //zahoor
        //Adding tap gesture on whole restaurant view
        let tgrOnRestaurant1 = UITapGestureRecognizer(target: self, action: #selector(DiningCityView.tappedOnRestaurant(_:)))
        restaurant1ContainerView.addGestureRecognizer(tgrOnRestaurant1)
        let tgrOnRestaurant2 = UITapGestureRecognizer(target: self, action: #selector(DiningCityView.tappedOnRestaurant(_:)))
        restaurant2ContainerView.addGestureRecognizer(tgrOnRestaurant2)
        //Add tap gestures on heart image
        let tgrOnHeart1 = UITapGestureRecognizer(target: self, action: #selector(DiningCityView.tappedOnHeart(_:)))
        imgHeart1.addGestureRecognizer(tgrOnHeart1)
        //Image heart 2
        let tgrOnHeart2 = UITapGestureRecognizer(target: self, action: #selector(DiningCityView.tappedOnHeart(_:)))
        imgHeart2.addGestureRecognizer(tgrOnHeart2)
    }
    
    private func setupViewUI() {
        cityNameLabel.text = city?.name
        restaurant2ContainerView.isHidden = true
        
        for (index, restaurant) in city?.restaurants.enumerated() ?? [].enumerated() {
            if index == 0 {
                restaurant1ImageView.downloadImageFrom(link: restaurant.primaryMedia?.mediaUrl ?? "", contentMode: .scaleAspectFill)
                restaurant1NameLabel.text = restaurant.name
                restaurant1locationContainerView.isHidden = restaurant.location.count == 0
                restaurant1locationLabel.text = restaurant.location.first?.city?.name.uppercased()
                restaurant1starImageContainerView.isHidden = restaurant.michelinStar?.count ?? 0 == 0
                restaurant1starCountLabel.text = restaurant.michelinStar?.first?.name.uppercased()
                //Zahoor
                //checking favourite image red or white
                if (restaurant.isFavourite ?? false){
                    imgHeart1.image = UIImage(named: "heart_red")
                }else{
                    imgHeart1.image = UIImage(named: "heart_white")
                }
                
            } else if index == 1 {
                restaurant2ContainerView.isHidden = false
                
                restaurant2ImageView.downloadImageFrom(link: restaurant.primaryMedia?.mediaUrl ?? "", contentMode: .scaleAspectFill)
                restaurant2NameLabel.text = restaurant.name
                restaurant2locationContainerView.isHidden = restaurant.location.count == 0
                restaurant2locationLabel.text = restaurant.location.first?.city?.name.uppercased()
                restaurant2starImageContainerView.isHidden = restaurant.michelinStar?.count ?? 0 == 0
                restaurant2starCountLabel.text = restaurant.michelinStar?.first?.name.uppercased()
                //Zahoor
                //checking favourite image red or white
                if (restaurant.isFavourite ?? false){
                    imgHeart2.image = UIImage(named: "heart_red")
                }else{
                    imgHeart2.image = UIImage(named: "heart_white")
                }
            }
        }
    }
    
    @IBAction func seeAllButton_onClick(_ sender: Any) {
        if let city = city {
            delegate?.seeAllRestaurantsForCity(city: city, view: self)
        }
    }
    
//    @IBAction func seeRestaurantDetailsButton_onClick(_ sender: UIButton) {
//        if let restaurant = city?.restaurants[sender.tag] {
//            delegate?.seeSelectedRestaurant(restaurant: restaurant)
//        }
//    }
    
    //Zahoor start
    @objc func tappedOnHeart(_ sender:AnyObject){
        if let restaurant = city?.restaurants[sender.view.tag] {
            delegate?.didTappedOnHeartAt(index: sender.view.tag, sender: restaurant)
        }
    }
    
    @objc func tappedOnRestaurant(_ sender:AnyObject){
        if let restaurant = city?.restaurants[sender.view.tag] {
            delegate?.didTappedOnRestaurantAt(restaurant: restaurant)
        }
    }
    //Zahoor end
}
