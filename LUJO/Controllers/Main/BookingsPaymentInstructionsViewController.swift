//
//  BookingsPaymentInstructionsViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class BookingsPaymentInstructionsViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "BookingsPaymentInstructionsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(booking: Booking, showAdditionalInfo: Bool) -> BookingsPaymentInstructionsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! BookingsPaymentInstructionsViewController
        viewController.booking = booking
        viewController.showAdditionalInfo = showAdditionalInfo
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet var noteLabel: UILabel!
    
    private(set) var booking: Booking!
    private(set) var showAdditionalInfo: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Wire transfer instructions"

        var price: Double = 0.0
        
        if let bookingPrice = booking.bookingQuote {
            price = bookingPrice
        } else if let bookingAviation = booking.bookingAviation {
            if showAdditionalInfo {
                var totalAdditionalExpenses: Double = 0.0
                
                if let expenses = bookingAviation.additionalExpenses {
                    for expense in expenses {
                        for aFee in expense.fees {
                            switch aFee.type {
                            case "fixed":
                                totalAdditionalExpenses += aFee.amount
                            default:
                                totalAdditionalExpenses += (aFee.amount * expense.price / 100)
                            }
                        }
                    }
                }
                
                price = totalAdditionalExpenses
            } else {
                price = bookingAviation.prices?.totalPrice ?? 0.0
            }
        }
        
        noteLabel.text = """
        Please note: paying for the booking via bank transfer entails the following:
        
        1. The USD 500.00 initially put on authorization hold will remain reserved until the wire transfer transaction is settled
        
        2. You are required to wire an amount equalling to the full price of the booking, which implies that the account you intend to wire money from must must contain sufficient funds.
        
        3. Once the new transaction is settled, the initially authorized amount will be manually released by the responsible agent.
        
        To make a payment, please wire a total of $\(MyBookingsCell.formatter.string(from: price as NSNumber) ?? "-") to:
        """
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
