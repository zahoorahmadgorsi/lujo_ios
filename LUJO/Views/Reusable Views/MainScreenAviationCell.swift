//
//  MainScreenAviationCell.swift
//  LUJO
//
//  Created by Kristian Iker on 9/23/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class MainScreenAviationCell: UICollectionViewCell {

    class var identifier: String { return "MainScreenAviationCell" }
    
    @IBOutlet weak var airportNameLabel: UILabel!
    @IBOutlet weak var airportShortTitleLabel: UILabel!
    @IBOutlet weak var airportLongTitleLabel: UILabel!
    
}
