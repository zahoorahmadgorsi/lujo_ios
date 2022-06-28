//
//  SearchCell.swift
//  LUJO
//
//  Created by zahoor gorsi on 22/06/2022.
//  Copyright © 2020 Baroque Access. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    @IBOutlet weak var lblSearch: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    private func reset() {
        lblSearch.text = ""
    }
    
}
