//
//  BookingDetailCell.swift
//  LUJO
//
//  Created by Nemanja Djurisic on 10/22/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

protocol BookingDetailCellDelegate: class {
    func showPaymentInstructions(cell: BookingDetailCell)
}

class BookingDetailCell: UITableViewCell {
    static var cellID = "BookingDetailCell"

    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var viewDetailsButton: UIButton!
    
    weak var delegate: BookingDetailCellDelegate?
    
    var bookingInfo: Booking? {
        didSet {
            setupData()
            
            self.layoutSubviews()
            self.updateConstraints()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setupData() {
        typeImageView.image = getImageForType()
        descriptionLabel.text = bookingInfo?.bookingMessage ?? bookingInfo?.booking ?? "There is no message for this request."
        timeStackView.isHidden = bookingInfo?.bookingDate == nil
        timeZoneLabel.text = ""
        statusLabel.text = bookingInfo?.bookingStatus?.uppercased()
        viewDetailsButton.isHidden = bookingInfo?.bookingQuote == nil || bookingInfo?.bookingStatus?.lowercased() != "payment"
        
        if let bookingDate = bookingInfo?.bookingDate {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "GMT")
            formatter.dateFormat = "dd MMM HH:mm'h'"
            timeLabel.text = formatter.string(from: bookingDate)
        }
    }
    
    private func getImageForType() -> UIImage? {
        if bookingInfo?.bookingType == "event" {
            return UIImage(named: "Event Icon White")
        } else if bookingInfo?.bookingType == "experience" {
            return UIImage(named: "Experience Icon White")
        } else if bookingInfo?.bookingType == "restaurant" {
            return UIImage(named: "Dining Icon White")
        }
        
        return nil
    }
    
    @IBAction func viewDetailButton_onClick(_ sender: UIButton) {
        delegate?.showPaymentInstructions(cell: self)
    }
    
    func formattedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: bookingInfo?.bookingQuote ?? 0)) ?? "0.00"
    }
}
