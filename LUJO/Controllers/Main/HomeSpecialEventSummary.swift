//
//  HomeSpecialEventSummary.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 7/16/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class HomeSpecialEventSummary: UIView {
    private static let kCONTENTXIBNAME = "HomeSpecialEventSummary"
    @IBOutlet var contentView: UIView!
    @IBOutlet var primaryImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet var tagLabel: UILabel!

    @IBOutlet var locationContainerView: UIView!
    @IBOutlet var dateContainerView: UIView!

    @IBOutlet weak var viewHeart: UIView!
    @IBOutlet weak var imgHeart: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        Bundle.main.loadNibNamed(HomeSpecialEventSummary.kCONTENTXIBNAME, owner: self, options: nil)
        contentView.fixInView(self)

    }

    func updateInformation(with data: Any?) {
        guard let data = data else {
            fillWithEmptyInformation()
            return
        }

        if let event = data as? Product, event.type == "special-event" {
//            specialEvent = event
            if let mediaLink = event.primaryMedia?.mediaUrl, event.primaryMedia?.type == "image" {
                primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
            }
            
            name.text = event.name

            if event.tags?.count ?? 0 > 0, let fistTag = event.tags?[0] {
                tagLabel.text = fistTag.name.uppercased()
                tagContainerView.isHidden = false
            } else {
                tagContainerView.isHidden = true
            }

            if (event.isFavourite ?? false){
                imgHeart.image = UIImage(named: "heart_red")
            }else{
                imgHeart.image = UIImage(named: "heart_white")
            }
            return
        }

        fillWithEmptyInformation()
    }

    func fillWithEmptyInformation() {
        primaryImage.image = UIImage(named: "placeholder-img")
        name.text = ""
        tagLabel.text = "SPECIAL EVENT"
    }
}
