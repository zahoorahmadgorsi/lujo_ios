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
        timeZoneLabel.text = ""
        
        statusLabel.text = bookingInfo?.bookingStatus?.uppercased()
        viewDetailsButton.isHidden = bookingInfo?.bookingQuote == nil || bookingInfo?.bookingStatus?.lowercased() != "payment"
        
        if let date = bookingInfo?.bookingCreation ?? bookingInfo?.bookingDate{
            timeLabel.text = Date.dateToString(date: date, format: "dd MMM HH:mm'h'")
        }else{
            timeStackView.isHidden = true
        }
    }
    
    private func getImageForType() -> UIImage? {
//        print(bookingInfo?.bookingType)
        if bookingInfo?.bookingType == "event" {
            return UIImage(named: "Event Icon White")
        } else if bookingInfo?.bookingType == "experience" {
            return UIImage(named: "Experience Icon White")
        } else if bookingInfo?.bookingType == "restaurant" {
            return UIImage(named: "dining grey icon")
        }else if bookingInfo?.bookingType == "gift" {
            return UIImage(named: "gift grey icon")
        } else if bookingInfo?.bookingType == "aviation" {
            return UIImage(named: "aviation_sel")
        } else if bookingInfo?.bookingType == "hotel" {
            return UIImage(named: "travel grey icon")
        }else if bookingInfo?.bookingType == "villa" {
            return UIImage(named: "villa grey icon")
        }else if bookingInfo?.bookingType == "yacht" {
            return UIImage(named: "yacht grey icon")
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
