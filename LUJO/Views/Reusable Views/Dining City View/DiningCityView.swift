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
    func seeSelectedRestaurant(restaurant: Restaurants)
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
    
    @IBOutlet weak var restaurant2ContainerView: UIView!
    @IBOutlet weak var restaurant2ImageView: UIImageView!
    @IBOutlet weak var restaurant2NameLabel: UILabel!
    @IBOutlet weak var restaurant2locationLabel: UILabel!
    @IBOutlet weak var restaurant2locationContainerView: UIView!
    @IBOutlet weak var restaurant2starCountLabel: UILabel!
    @IBOutlet weak var restaurant2starImageContainerView: UIView!
    
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
            } else if index == 1 {
                restaurant2ContainerView.isHidden = false
                
                restaurant2ImageView.downloadImageFrom(link: restaurant.primaryMedia?.mediaUrl ?? "", contentMode: .scaleAspectFill)
                restaurant2NameLabel.text = restaurant.name
                restaurant2locationContainerView.isHidden = restaurant.location.count == 0
                restaurant2locationLabel.text = restaurant.location.first?.city?.name.uppercased()
                restaurant2starImageContainerView.isHidden = restaurant.michelinStar?.count ?? 0 == 0
                restaurant2starCountLabel.text = restaurant.michelinStar?.first?.name.uppercased()
            }
        }
    }
    
    @IBAction func seeAllButton_onClick(_ sender: Any) {
        if let city = city {
            delegate?.seeAllRestaurantsForCity(city: city, view: self)
        }
    }
    @IBAction func seeRestaurantDetailsButton_onClick(_ sender: UIButton) {
        if let restaurant = city?.restaurants[sender.tag] {
            delegate?.seeSelectedRestaurant(restaurant: restaurant)
        }
    }
}
